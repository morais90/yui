import QtQuick
import QtQuick.Shapes
import qs.services

// Yui logo: a "Y" drawn as three branches of a network meeting at a glowing
// core, a nod to the AI at the heart of the system.
Item {
    id: root

    readonly property real designWidth: 128
    readonly property real designHeight: 128

    property color topColour: Colours.palette.m3primary
    property color bottomColour: Colours.palette.m3onSurface

    implicitWidth: designWidth
    implicitHeight: designHeight

    Shape {
        anchors.centerIn: parent
        width: root.designWidth
        height: root.designHeight
        scale: Math.min(root.width / width, root.height / height)
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer

        // Branches
        ShapePath {
            strokeColor: root.bottomColour
            strokeWidth: 16
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg {
                path: "M26 22 L64 66 L102 22 M64 66 L64 110"
            }
        }

        // Core
        ShapePath {
            strokeColor: "transparent"
            fillColor: root.topColour

            PathAngleArc {
                centerX: 64
                centerY: 66
                radiusX: 17
                radiusY: 17
                startAngle: 0
                sweepAngle: 360
            }
        }

        // Branch tips
        ShapePath {
            strokeColor: "transparent"
            fillColor: root.topColour

            PathAngleArc {
                centerX: 26
                centerY: 22
                radiusX: 6
                radiusY: 6
                startAngle: 0
                sweepAngle: 360
            }
        }

        ShapePath {
            strokeColor: "transparent"
            fillColor: root.topColour

            PathAngleArc {
                centerX: 102
                centerY: 22
                radiusX: 6
                radiusY: 6
                startAngle: 0
                sweepAngle: 360
            }
        }
    }
}
