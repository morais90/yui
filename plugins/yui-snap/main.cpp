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

#include <format>
#include <string>

#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
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

    return {"yui-snap", "macOS-style window snapping for Yui", "Yui", "0.1"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    setZone("none", "");
}
