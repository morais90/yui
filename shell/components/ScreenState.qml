import Quickshell

PersistentProperties {
    required property ShellScreen modelData

    // Drawer visibilities
    property bool bar
    property bool osd
    property bool session
    property bool launcher
    property bool utilities
    property bool sidebar

    // Month shown by the calendar popout on the bar clock
    property date calendarDate: new Date()
}
