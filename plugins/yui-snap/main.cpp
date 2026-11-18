// yui-snap: macOS-style window snapping for Hyprland.
//
// While a window is dragged, reports which screen edge or corner the pointer
// touches, and when the window is dropped there, asks for it to be snapped.
// The plugin only detects; the Yui Shell draws the preview and `yui-snap`
// applies the geometry. Events on Hyprland's socket2:
//
//   yuisnap>>hint,<zone>,<monitor>              zone changed while dragging
//   yuisnap>>apply,<zone>,<monitor>,<address>   window dropped on a zone
//
// zone: none | left | right | top | topleft | topright | bottomleft | bottomright
//
// It also fixes stacking around maximized windows (macOS-like): Hyprland keeps
// floating windows opened over a maximized one above it even when the
// maximized window is clicked. Focusing the maximized window now sends the
// others behind it; focusing one of them brings it back in front.
//
// And it completes apps' own window buttons (Chrome, GTK apps):
//   - minimize requests, which Hyprland ignores, run `yui-minimize`;
//   - Hyprland tells every app it is maximized (so GTK drops its shadows) and
//     treats any maximize request as a toggle. Apps with their own maximize
//     button then lose track after the first click and the button goes dead.
//     Apps that draw their own title bar (no Hyprbar), and any app that asks
//     to (un)maximize, are told their real state and get what they asked for.

#include <format>
#include <spawn.h>
#include <unordered_map>
#include <string>

#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/desktop/state/WindowState.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/view/window/WindowBackend.hpp>
#include <hyprland/src/desktop/view/window/WindowFullscreenPolicy.hpp>
#include <hyprland/src/desktop/view/window/WindowPresentation.hpp>
#include <hyprland/src/protocols/XDGShell.hpp>
#include <hyprland/src/render/decorations/IHyprWindowDecoration.hpp>
#include <hyprland/src/protocols/core/Compositor.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/managers/eventLoop/EventLoopManager.hpp>
#include <hyprland/src/managers/fullscreen/FullscreenController.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/ipc/s2/S2.hpp>
#include <hyprland/src/layout/LayoutManager.hpp>
#include <hyprland/src/managers/input/InputManager.hpp>
#include <hyprland/src/output/Monitor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/state/MonitorState.hpp>

static HANDLE PHANDLE = nullptr;

// How close (logical px) the pointer must get to an edge
static constexpr double EDGE = 12.0;
// Corners trigger within this distance along the edge
static constexpr double CORNER = 120.0;

static struct {
    std::string zone = "none";
    std::string monitor;
    PHLWINDOWREF window;
} g_state;

static void post(const std::string& data) {
    IPC::Socket2::sock()->postEvent({.event = "yuisnap", .data = data});
}

static void setZone(const std::string& zone, const std::string& monitor) {
    if (zone == g_state.zone && monitor == g_state.monitor)
        return;
    g_state.zone    = zone;
    g_state.monitor = monitor;
    post(std::format("hint,{},{}", zone, monitor));
}

static std::string zoneAt(const CBox& box, const Vector2D& p) {
    const bool left   = p.x <= box.x + EDGE;
    const bool right  = p.x >= box.x + box.w - EDGE;
    const bool top    = p.y <= box.y + EDGE;
    const bool bottom = p.y >= box.y + box.h - EDGE;
    const bool nearL  = p.x <= box.x + CORNER;
    const bool nearR  = p.x >= box.x + box.w - CORNER;
    const bool nearT  = p.y <= box.y + CORNER;
    const bool nearB  = p.y >= box.y + box.h - CORNER;

    if ((top && nearL) || (left && nearT))
        return "topleft";
    if ((top && nearR) || (right && nearT))
        return "topright";
    if ((bottom && nearL) || (left && nearB))
        return "bottomleft";
    if ((bottom && nearR) || (right && nearB))
        return "bottomright";
    if (left)
        return "left";
    if (right)
        return "right";
    if (top)
        return "top";
    return "none";
}

static void onMotion() {
    const auto& drag = g_layoutManager->dragController();
    if (drag->mode() != MBIND_MOVE || !drag->dragThresholdReached()) {
        setZone("none", "");
        return;
    }

    const auto target = drag->target();
    const auto window = target ? target->window() : nullptr;
    if (!window) {
        setZone("none", "");
        return;
    }
    g_state.window = window;

    const auto pos = g_pInputManager->getMouseCoordsInternal();
    for (const auto& m : State::monitorState()->monitors()) {
        const auto box = m->logicalBox();
        if (box.containsPoint(pos)) {
            setZone(zoneAt(box, pos), m->m_name);
            return;
        }
    }
    setZone("none", "");
}

static void onEnded() {
    const auto window = g_state.window.lock();
    if (window && g_state.zone != "none")
        post(std::format("apply,{},{},0x{:x}", g_state.zone, g_state.monitor, reinterpret_cast<uintptr_t>(window.get())));
    setZone("none", "");
    g_state.window.reset();
}

static void setOverFullscreen(PHLWINDOW w, bool allowed) {
    if (w->fullscreenPolicy().allowedOverFullscreen() == allowed)
        return;
    w->fullscreenPolicy().setAllowedOverFullscreen(allowed);
    w->updateFullscreenInputState();
    // Windows below a fullscreen/maximized one are faded out by Hyprland
    *w->presentation().alpha(Desktop::View::WINDOW_ALPHA_FULLSCREEN) = allowed ? 1.F : 0.F;
    g_pHyprRenderer->damageWindow(w, true);
}

static void onActive(PHLWINDOW focused) {
    if (!focused || !focused->m_workspace)
        return;

    const auto& fs  = Fullscreen::controller();
    const auto  max = fs->getFullscreenWindow(focused->m_workspace, std::nullopt);
    // Only maximized windows; real fullscreen (games, videos) keeps Hyprland's behaviour
    if (!max || !fs->isFullscreen(max, Fullscreen::FSMODE_MAXIMIZED))
        return;

    if (focused == max) {
        for (const auto& w : Desktop::windowState()->windows()) {
            if (w != max && w->mapped() && w->m_workspace == max->m_workspace)
                setOverFullscreen(w, false);
        }
    } else
        setOverFullscreen(focused, true);
}

extern char** environ;

static void spawn(const std::vector<std::string>& args) {
    std::vector<char*> argv;
    for (const auto& a : args)
        argv.push_back(const_cast<char*>(a.c_str()));
    argv.push_back(nullptr);
    pid_t pid;
    posix_spawnp(&pid, argv[0], nullptr, nullptr, argv.data(), environ);
}

static std::string addressOf(PHLWINDOW w) {
    return std::format("0x{:x}", reinterpret_cast<uintptr_t>(w.get()));
}

// Per-window listeners on the app's state requests
struct STracked {
    PHLWINDOWREF        window;
    CHyprSignalListener listener;
};
static std::unordered_map<Desktop::View::CWindow*, STracked> g_requests;

// Windows told their real maximized state
static std::unordered_map<Desktop::View::CWindow*, bool> g_truthful;

static SP<CXDGToplevelResource> toplevelOf(PHLWINDOW w) {
    const auto surface = w->resource();
    if (!surface || !surface->m_role || surface->m_role->role() != SURFACE_ROLE_XDG_SHELL)
        return nullptr;
    const auto xdg = static_cast<CXDGSurfaceRole*>(surface->m_role.get())->m_xdgSurface.lock();
    return xdg ? xdg->m_toplevel.lock() : nullptr;
}

static void syncMaximized(PHLWINDOW w) {
    if (const auto toplevel = toplevelOf(w))
        toplevel->setMaximized(Fullscreen::controller()->isFullscreen(w, Fullscreen::FSMODE_MAXIMIZED));
}

static void onStateRequest(PHLWINDOWREF ref, const Desktop::View::SBackendStateRequest& req) {
    const auto w = ref.lock();
    if (!w)
        return;

    if (req.minimized.value_or(false))
        spawn({"yui-minimize", addressOf(w)});

    // Hyprland turns any maximize request into a toggle; honour the app's
    // actual request instead (still readable while the signal is emitted)
    const auto toplevel = toplevelOf(w);
    if (req.maximized.has_value() && toplevel && toplevel->m_state.requestsMaximize.has_value()) {
        const bool wanted = toplevel->m_state.requestsMaximize.value();
        g_truthful[w.get()] = true;
        if (Fullscreen::controller()->isFullscreen(w, Fullscreen::FSMODE_MAXIMIZED) != wanted)
            Fullscreen::controller()->setFullscreenMode(w, std::nullopt, wanted ? Fullscreen::FSMODE_MAXIMIZED : Fullscreen::FSMODE_NONE);
        syncMaximized(w);
    }
}

static void track(PHLWINDOW w) {
    if (!w)
        return;
    // A new window may reuse a destroyed one's address
    if (const auto it = g_requests.find(w.get()); it != g_requests.end() && it->second.window.lock() == w)
        return;
    PHLWINDOWREF ref       = w;
    g_requests[w.get()]    = {ref, w->backend().m_events.stateRequest.listen([ref](const Desktop::View::SBackendStateRequest& req) { onStateRequest(ref, req); })};
    g_truthful.erase(w.get());
}

// Apps drawing their own title bar get the truth from the start
static void checkOwnTitleBar(PHLWINDOW w) {
    if (!w)
        return;
    for (const auto& d : w->presentation().decorations()) {
        // A hidden bar (hyprbars:no_bar) stays attached but reserves no space
        if (d && d->getDisplayName() == "Hyprbar" && d->getPositioningInfo().desiredExtents.topLeft.y > 0)
            return;
    }
    g_truthful[w.get()] = true;
    syncMaximized(w);
}

static void onOpenLate(PHLWINDOW w) {
    // hyprbars drops its bar (no_bar rule) after the window opened
    PHLWINDOWREF ref = w;
    g_pEventLoopManager->doLater([ref] { checkOwnTitleBar(ref.lock()); });
}

static void untrack(Desktop::View::CWindow* w) {
    g_requests.erase(w);
    g_truthful.erase(w);
}

APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    // Both return C strings: compare the contents, not the pointers
    if (std::string{__hyprland_api_get_hash()} != std::string{__hyprland_api_get_client_hash()}) {
        HyprlandAPI::addNotification(PHANDLE, "[yui-snap] Version mismatch: rebuild the plugin for this Hyprland", CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
        throw std::runtime_error("[yui-snap] Version mismatch");
    }

    static auto motion = g_layoutManager->dragController()->m_events.motion.listen([] { onMotion(); });
    static auto ended  = g_layoutManager->dragController()->m_events.ended.listen([] { onEnded(); });
    static auto active = Event::bus()->m_events.window.active.listen([](PHLWINDOW w, Desktop::eFocusReason) { onActive(w); });
    static auto open   = Event::bus()->m_events.window.open.listen([](PHLWINDOW w) { track(w); });
    static auto fsEv   = Event::bus()->m_events.window.fullscreen.listen([](PHLWINDOW w) {
        if (w && g_truthful[w.get()])
            syncMaximized(w);
    });
    static auto openLate = Event::bus()->m_events.window.openLate.listen([](PHLWINDOW w) { onOpenLate(w); });
    static auto destroy = Event::bus()->m_events.window.destroy.listen([](PHLWINDOWREF w) { untrack(w.get()); });
    for (const auto& w : Desktop::windowState()->windows()) {
        track(w);
        if (w->mapped())
            checkOwnTitleBar(w);
    }

    return {"yui-snap", "macOS-style window snapping, stacking and buttons for Yui", "Yui", "0.3"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    setZone("none", "");
}
