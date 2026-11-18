import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.filedialog
import qs.services
import qs.modules.dashboard.dash

GridLayout {
    id: root

    required property ScreenState screenState
    required property FileDialog facePicker

    rowSpacing: Tokens.spacing.medium
    columnSpacing: Tokens.spacing.medium

    Rect {
        Layout.row: 0
        Layout.column: 0
        Layout.columnSpan: 2
        Layout.fillWidth: true
        Layout.preferredWidth: Tokens.sizes.dashboard.userWidth
        Layout.preferredHeight: 120 // the user card fills its row; nothing else sets its height

        radius: Tokens.rounding.extraLarge

        User {
            id: user

            screenState: root.screenState
            facePicker: root.facePicker
        }
    }

    Rect {
        Layout.row: 1
        Layout.preferredWidth: dateTime.implicitWidth
        Layout.preferredHeight: 260 // sets the row height; the cards in it fill it

        radius: Tokens.rounding.large

        DateTime {
            id: dateTime
        }
    }

    Rect {
        Layout.row: 1
        Layout.column: 1
        Layout.fillWidth: true
        Layout.preferredWidth: resources.implicitWidth
        Layout.fillHeight: true

        radius: Tokens.rounding.large

        Resources {
            id: resources

            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Rect {
        Layout.row: 0
        Layout.column: 2
        Layout.rowSpan: 2
        Layout.preferredWidth: media.implicitWidth
        Layout.fillHeight: true

        radius: Tokens.rounding.extraLarge * 2

        Media {
            id: media
        }
    }

    component Rect: StyledRect {
        color: Colours.tPalette.m3surfaceContainer
    }
}
