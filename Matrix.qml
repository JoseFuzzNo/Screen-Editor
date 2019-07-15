import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    id: root

    property int rows: 3
    property int columns: 3
    property int size: 5

    property color color: "yellow"
    property color secondColor: "#444444"
    property color backgroundColor: "#333333"

    property alias background: background


    width: size * columns
    height: size * rows

    signal statusChanged( var x, var y, int value )
    signal matrixModified( )

    function setPixel( x, y, value ) {
        var index = x + y * root.columns;
        if ( repeater.itemAt( index ) !== null )
            repeater.itemAt( index ).color = value ? color : secondColor
    }

    function getPixel( x, y ) {
        var index = x + y * root.columns;
        return repeater.itemAt( index ).color === color
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.backgroundColor
        radius: 2
    }


    MouseArea {

        anchors.fill: parent
        property int lastIndex: 0
        property int action: 0
        hoverEnabled: true

        onPressed: {
            var column = parseInt( mouseX / size );
            var row = parseInt( mouseY / size );

            var index = column + row * root.columns;
            action = repeater.itemAt( index ).color === root.color ? 0 : 1;
            setPixel( column, row, action )
            statusChanged( column, row, action )
        }
        onPositionChanged: {
            var column = parseInt( mouseX / size );
            var row = parseInt( mouseY / size );
            if ( column >= root.columns )       column = root.columns - 1;
            else if ( column < 0 )              column = 0;

            if ( row >= root.rows )             row = root.rows - 1;
            else if ( row < 0 )                 row = 0;

            var index = column + row * root.columns
            if ( index !== lastIndex ) {
                lastIndex = index
                if ( pressed ) {
                    setPixel( column, row, action )
                    statusChanged( column, row, action )
                }
                tooltip.text = "(" + column + "," + row + ")"
            }

        }
        onEntered: tooltip.visible = true
        onExited: tooltip.visible = false



        Grid {
            id: grid
            rows: root.rows
            columns: root.columns
            Repeater {
                id: repeater
                model: rows * columns
                onModelChanged: matrixModified( )
                Item {
                    width: root.size
                    height: root.size
                    property color color: root.secondColor
                    property real scale: 1

                    Rectangle {
                        clip: true
                        color: parent.color
                        scale : parent.scale

                        anchors.rightMargin: root.size / 20
                        anchors.leftMargin: anchors.rightMargin
                        anchors.bottomMargin: root.size / 20
                        anchors.topMargin: anchors.bottomMargin
                        anchors.fill: parent

                    }
                }
            }
        }
        ToolTip {
            id: tooltip
            background: Rectangle {
                color: "#999"
                radius: 2
            }
            delay: 1000
            //timeout: 1000
        }
    }





}
