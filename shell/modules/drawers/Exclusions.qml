pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components.containers
import qs.services
import qs.modules.bar as Bar

Scope {
    id: root

    required property ShellScreen screen
    required property Bar.BarWrapper bar
    required property Item dock

    ExclusionZone {
        anchors.left: true
        exclusiveZone: root.bar.exclusiveZone
    }

    ExclusionZone {
        anchors.top: true
    }

    ExclusionZone {
        anchors.right: true
    }

    // Reserve room for the Yui dock so windows don't go under it
    ExclusionZone {
        anchors.bottom: true
        exclusiveZone: contentItem.Config.border.thickness + (YuiWindows.dockAutoHide ? 0 : root.dock.implicitHeight)
    }

    component ExclusionZone: StyledWindow {
        screen: root.screen
        name: "border-exclusion"
        exclusiveZone: contentItem.Config.border.thickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
}
