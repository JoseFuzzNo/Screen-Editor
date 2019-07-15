import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

Window {
    visible: true
    width: 1500
    height: 850
    title: qsTr("Screen Editor")
    color: "#CCC"

    property int defaultScreenWidth: 128
    property int defaultScreenHeight: 64

    property variant matrixData: [[],[]]

    function initializeBuffer( ) {
        for ( var x = 0; x < screen.columns; x++ )
            for ( var y = 0; y < screen.rows; y++ )
            matrixData[x][y] = 0
    }

    function refresh( ) {
        for ( var x = 0; x < screen.columns; x++ )
            for ( var y = 0; y < screen.rows; y++ ) {
                if ( matrixData[x] === undefined )      matrixData[x] = []
                if ( matrixData[x][y] === undefined )   matrixData[x][y] = 0
                screen.setPixel( x, y, matrixData[x][y] )
            }
    }

    function clearScreen( ) {
        initializeBuffer( )
        refresh( )
    }

    function generateCode( ) {
        var dataStr = "const unsigned char screen[] = {"
        for ( var y = 0; y < screen.rows; y++ ) {
            dataStr += "\n\t"
            for ( var x = 0; x < screen.columns; x++ ) {
                if ( x === 0 )
                    dataStr += "0b"
                else if ( x % 8 === 0 )
                    dataStr += ", 0b"

                dataStr += matrixData[x][y]
            }
            dataStr += ","
        }
        dataStr += "\n};"
        return dataStr
    }

    function openFile( fileName ) {
        var request = new XMLHttpRequest();
        request.open("GET", fileName, false);
        request.send( null );
        var buffer = request.responseText.split( ',' )
        var width = buffer[0]
        var height = buffer[1]
        clearScreen( )
        columnsSpinBox.value = width
        rowsSpinBox.value = height
        for ( var y= 0; y < height; y++ )
            for ( var x = 0; x < width; x++ ) {
                matrixData[x][y] = parseInt( buffer[2 + x + y * width] )
            }
        refresh( )
    }

    function saveToFile( fileName ) {
        var dataStr = "" + screen.columns + "," + screen.rows + ","
        for ( var y= 0; y < screen.rows; y++ )
            for ( var x = 0; x < screen.columns; x++ )
                dataStr += matrixData[x][y] + ","

        var request = new XMLHttpRequest();
        request.open( "PUT", fileName, false );
        request.send( dataStr );
        return request.status;
    }

    Component.onCompleted: {
        initializeBuffer( )
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent

        RowLayout {
            id: toolBarLayout
            Button {
                onClicked: openDialog.open( )
                text: qsTr( "Open" )
            }
            Button {
                onClicked: saveDialog.open( )
                text: qsTr( "Save" )
            }
            Button {
                onClicked: txtGeneratedCode.text = generateCode( )
                text: qsTr( "Generate" )
            }
            Button {
                onClicked: clearScreen( )
                text: qsTr( "Clear" )
            }

            Item {
                Layout.fillWidth: true
            }

            Slider {
                id: zoomSlider
                value: 0.25
            }
            Text {
                text: qsTr( "Columns:" )
            }
            SpinBox {
                id: columnsSpinBox
                value: defaultScreenWidth
                from: 1
                to: 512
                editable: true
            }

            Text {
                text: qsTr( "Rows:" )
            }
            SpinBox {
                id: rowsSpinBox
                value: defaultScreenHeight
                from: 1
                to: 512
                editable: true
            }

        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#222"
            ScrollView {
                anchors.fill: parent
                clip: true
                Matrix {
                    id: screen
                    anchors.centerIn: parent
                    columns: columnsSpinBox.value
                    rows: rowsSpinBox.value
                    size: ( zoomSlider.value * 40 ) + 1
                    color: "#EB0"
                    backgroundColor: "#333"
                    onStatusChanged: {
                        matrixData[x][y] = value
                    }
                    //onColumnsChanged: refresh( )
                    //onRowsChanged: refresh( )
                    onMatrixModified: refresh( )
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.maximumHeight: 100
            Layout.maximumWidth: parent.width
            clip: true
            TextArea {
                id: txtGeneratedCode
                font.pixelSize: 12
                selectByMouse: true
            }


        }
    }




    FileDialog {
        id: openDialog
        title: "Open file"
        folder: shortcuts.home

        nameFilters: [ "OLED files (*.oled)", "All files (*)" ]

        onAccepted: {
            openFile( openDialog.fileUrl )
        }

    }

    FileDialog {
        id: saveDialog
        title: "Save to file..."
        folder: shortcuts.home
        selectExisting: false

        nameFilters: [ "OLED files (*.oled)", "All files (*)" ]

        onAccepted: saveToFile( saveDialog.fileUrls )
    }
}
