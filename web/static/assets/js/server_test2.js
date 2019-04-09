function delay_run() {
    $(document).ready(function () {
        $('#refresh_bt').click(refresh_bt_on_click);
        $('#clear_remoting_log_bt').click(clear_remoting_log);
        $('#server_status_bt').click(server_status_bt_on_click);
        $('#server_hot_update_bt').click(server_hot_update_bt_on_click)
        $('#websocket_status_bt').click(websocket_status_bt_on_click);
        $('#clear_local_log_bt').click(clear_client_log);
        $('#http_send_bt').click(function () {
            $.get(http_url + $.trim($('#http_send_value').val()), function (data, status) {
                // alert("Data: " + data + "\nStatus: " + status);
                client_log(data);
                //refresh_bt_on_click();
            });
        });
        $('#websocket_send_bt').click(function () {
            if (ws) {
                var websocket_send_value = $('#websocket_send_value').val();
                channel.push("request", websocket_send_value);
            }
        });
        $('#websocket_send_json_bt').click(function () {
            if (ws) {
                try {
                    var websocket_send_value = $('#websocket_send_value').val();
                    channel.push("request", JSON.parse(websocket_send_value));
                } catch (err) {
                    client_log("send data json format error!")
                }
            }
        });
        change_server_status();
        change_socket_status();
        refresh_bt_on_click();
    });
}

function timestamp_format(timestamp) {
    var unixTimestamp = new Date(timestamp * 1000)
    return "[" + unixTimestamp.toLocaleString() + "]"
}

// 改变按钮显示方式
function change_server_status() {
    if (is_server_running) {
        $("#server_status_bt").text("Stop");
        $('#server_hot_update_bt').show();
        $("#server_status_txt").text("started");
        change_cls("#server_status_bt", "btn-primary", "btn-danger")
        $("#server_status_txt").css("color", "green");
    } else {
        $("#server_status_bt").text("Start");
        $('#server_hot_update_bt').hide();
        $("#server_status_txt").text("stoped");
        change_cls("#server_status_bt", "btn-danger", "btn-primary")
        $("#server_status_txt").css("color", "red");
    }
}

function change_socket_status() {
    if (ws) {
        $("#websocket_status_bt").text("Close");
        $("#websocket_status_txt").text("open");
        $("#websocket_status_txt").css("color", "green");
        change_cls("#websocket_status_bt", "btn-primary", "btn-danger");
    } else {
        $("#websocket_status_bt").text("Open");
        $("#websocket_status_txt").text("close");
        $("#websocket_status_txt").css("color", "red");
        change_cls("#websocket_status_bt", "btn-danger", "btn-primary")
    }
}

function change_cls(id, old_cls, new_cls) {
    $(id).removeClass(old_cls);
    $(id).addClass(new_cls);
}

function disable_all_bt() {
    $("button").attr("disabled", "true")
}

function enable_all_bt() {
    $("button").removeAttr("disabled");
}

function disable_bt(id) {
    $("#" + id).attr("disabled", "true")
    $("#server_status_bt").removeAttr("disabled");
}

function enable_bt(id) {
    $("#" + id).removeAttr("disabled");
}
var const_code = {
    1001: "manual shutdown",
    1002: "normal shutdown",
    1003: "unknow shutdown",
    1004: "no such server",
    2001: "start up",
    2002: "hot update done",
    3001: "load lua script error",
    3002: "run lua script error"
};

var refresh_bt_on_click = function () {
    disable_all_bt();
    $.ajax({
        url: refresh_url,
        type: "POST",
        dataType: "json",
        beforeSend: function (xhr) {
            xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
        },
        data: {
            id: server_id
        },
        success: function (log_info) {
            enable_all_bt();
            $("#refresh_bt").removeAttr("disabled");
            //console.log(log_info);
            var server_log_len = log_info.server_log.length;
            var output_str = "";
            for (var i = 0; i < server_log_len; i++) {
                var log_line = log_info.server_log[i];
                //["code", 1543369614, 2001]
                //["lua_print", 1543303565, "{"c":"get"}"]
                var type = log_line[0];
                var timestamp = log_line[1];
                var log_thing = log_line[2];
                if (timestamp > remoting_last_show_date) remoting_last_show_date = timestamp;
                if (timestamp > remoting_current_show_date) {
                    switch (type) {
                        case "code":
                            output_str = output_str + timestamp_format(timestamp) + "system message: " + const_code[log_thing] + "\n";
                            break;
                        case "lua_print":
                            output_str = output_str + timestamp_format(timestamp) + "lua print: " + log_thing + "\n";
                            break;
                        case "lua_error":
                            output_str = output_str + timestamp_format(timestamp) + "lua error: " + log_thing + "\n";
                            break;
                    }
                }
            }
            $("#server_log").html(output_str);
            is_server_running = log_info.is_server_running
            change_server_status();
        }
    });
}
var server_status_bt_on_click = function () {
    disable_all_bt();
    var url = "";
    if (is_server_running) {
        url = server_stop_url
    } else {
        url = server_start_url
    }
    $.ajax({
        url: url,
        type: "POST",
        dataType: "json",
        beforeSend: function (xhr) {
            xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
        },
        data: {
            id: server_id
        },
        success: function (any) {
            refresh_bt_on_click();
        }
    });
}

var server_hot_update_bt_on_click = function () {
    disable_all_bt();
    if (is_server_running) {
        $.ajax({
            url: server_hot_update_url,
            type: "POST",
            dataType: "json",
            beforeSend: function (xhr) {
                xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
            },
            data: {
                id: server_id
            },
            success: function (any) {
                refresh_bt_on_click();
            }
        });
    }
}

var websocket_status_bt_on_click = function () {
    disable_all_bt();
    if (ws) {
        ws = false;
        socket.conn.close();
        change_socket_status();
        refresh_bt_on_click();
    } else {
        ws_connect(get_uuid());
    }
}
var ws_connect = function (uuid) {
    socket = new Socket(websocket_url, {
        params: {
            server_token: get_server_token(),
            uuid: uuid
        },
        reconnectAfterMs: function (tries) {
            return 100000000
        }
    });
    socket.onOpen(function () {
        client_log(["socket on open", arguments]);
        websocket_join_bt_on_click();
        enable_all_bt();
    })
    socket.onClose(function () {
        client_log(["socket on close", arguments]);
        enable_all_bt();
    })
    socket.onError(function () {
        client_log(["socket on error", arguments]);
        enable_all_bt();
    })
    socket.onMessage(function () {
        //client_log(["socket on message", arguments]);
    })

    socket.connect();

}

var websocket_join_bt_on_click = function () {
    channel_join(get_server_token(), get_uuid());
}
var channel_join = function (server_token, uuid) {
    channel = socket.channel("ant:" + server_token, {
        uuid: uuid
    });
    channel.join().receive("ok", function (messages) {
            ws = true;
            client_log(["sucess join", messages])
            enable_all_bt();
            change_socket_status();
        })
        .receive("error", function (reason) {
            ws = false;
            change_socket_status();
            client_log(["failed join", reason])
        })
        .receive("timeout", () => client_log("Networking issue. Still waiting..."))
    channel.onClose(function () {
        ws = false;
        change_socket_status();
        client_log(["channel on close", arguments]);
    })
    channel.onError(function () {
        ws = false;
        change_socket_status();
        client_log(["channel on error", arguments]);
    })
    channel.on("response", function (msgObj) {
        client_log(msgObj);
    })
}

function client_log(v) {
    var old = $('#client_log').text();
    var log_data = "";
    try {
        log_data = JSON.stringify(v)
    } catch (err) {
        log_data = "log data json format error!"
    }
    $('#client_log').text("[" + new Date().toLocaleString() + "]" + log_data + "\n" + old);
}

function clear_client_log() {
    $('#client_log').text("");
}

function clear_remoting_log(){
    $('#server_log').text("");
    remoting_current_show_date = remoting_last_show_date;
}

// 从文本框获得 channel id
function get_server_token() {
    return $('#websocket_server_token').val();
}


// 从文本框获得 uuid
function get_uuid() {
    return $('#websocket_uuid').val();
}