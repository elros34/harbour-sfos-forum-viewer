/*
 * This file is part of harbour-sfos-forum-viewer.
 *
 * MIT License
 *
 * Copyright (c) 2020 szopin
 * Copyright (C) 2020 Mirian Margiani
 * Copyright (c) 2020 elros34
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page

    property alias postText: postTextEdit.text
    property alias username: mainMetadata.text
    property var created_at
    property var updated_at
    property var version
    property int likes: 0

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.height
        pressDelay: 0

        Column {
            id: column
            width: flickable.width

            Column {
                id: delegateCol
                width: parent.width - 2*Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium

                Item {
                    height: Theme.paddingMedium
                    width: 1
                }

                Row {
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Column {
                        width: parent.width - subMetadata.width

                        Label {
                            id: mainMetadata
                            text: username
                            textFormat: Text.RichText
                            truncationMode: TruncationMode.Fade
                            elide: Text.ElideRight
                            width: parent.width
                            font.pixelSize: Theme.fontSizeMedium
                        }
                        Label {
                            visible: likes > 0
                            text: qsTr("%n like(s)", "", likes)
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    Column {
                        id: subMetadata
                        Label {
                            text: formatJsonDate(created_at)
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.right: parent.right
                        }
                        Label {
                            text: (version > 1 && updated_at !== created_at) ?
                                      qsTr("✍️: %1").arg(formatJsonDate(updated_at)) : ""
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.right: parent.right
                        }
                    }
                }
            }

            TextArea {
                id: postTextEdit
                width: parent.width
                on_EditorChanged: if (_editor) _editor.textFormat = Text.RichText
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                labelVisible: false
                softwareInputPanelEnabled: false
                readOnly: false
                textRightMargin: 0
                _flickableDirection: Flickable.HorizontalFlick
                background: null
                z: 10
                // buggy
                autoScrollEnabled: false

                Component.onCompleted: {
                    _editor.width = _editor.contentWidth
                }

                // Hacky readonly mode with selection working
                property string initRichText
                onTextChanged: {
                    if (!initRichText.length)
                        initRichText = text
                    else if (text !== initRichText)
                        _editor.undo()
                }

                onClicked: {
                    var link = _editor.linkAt(mouse.x, mouse.y)
                    if (link.length)
                        application.openLink(link)
                }

                Item {
                    width: parent.width/3
                    height: postTextEdit._contentItem.height
                    z: parent.z - 1
                    Rectangle {
                        id: boundRect
                        width: parent.height
                        height: parent.width
                        anchors.centerIn: parent
                        opacity: 0
                        rotation: -90
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00;
                                color: "#ffffff";
                            }
                            GradientStop {
                                position: 1.00;
                                color: "transparent";
                            }
                        }
                        SequentialAnimation {
                            id: opacityAnim
                            NumberAnimation {
                                target: boundRect
                                property: "opacity"
                                to: 0.2
                            }
                            NumberAnimation {
                                target: boundRect
                                property: "opacity"
                                to: 0
                            }
                        }

                        Connections {
                            target: postTextEdit._contentItem
                            onContentXChanged: {
                                if (target.contentX === 0)
                                    opacityAnim.start()
                            }
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator {
            flickable: flickable
        }
    }
}
