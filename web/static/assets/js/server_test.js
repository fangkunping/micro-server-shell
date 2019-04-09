function delay_run() {
    $(document).ready(function () {
        $('#refresh_bt').click(refresh_bt_on_click);
        $('#server_status_bt').click(server_status_bt_on_click);
        $('#websocket_status_bt').click(websocket_status_bt_on_click);
        $('#clear_local_log_bt').click(clear_client_log);
        $('#websocket_send_bt').click(function () {
            if (ws) {
                var websocket_send_value = $('#websocket_send_value').val();
                WSocket.send(websocket_send_value);
            }
        });
        $('#websocket_send_json_bt').click(function () {
            if (ws) {
                var websocket_send_value = $('#websocket_send_value').val();
                WSocket.send(JSON.parse(websocket_send_value));
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
        $("#server_status_txt").text("started");
        change_cls("#server_status_bt", "btn-primary", "btn-danger")
        $("#server_status_txt").css("color", "green");
    } else {
        $("#server_status_bt").text("Start");
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
            console.log(log_info);
            var server_log_len = log_info.server_log.length;
            var output_str = "";
            for (var i = 0; i < server_log_len; i++) {
                var log_line = log_info.server_log[i];
                //["code", 1543369614, 2001]
                //["lua_print", 1543303565, "{"c":"get"}"]
                var type = log_line[0];
                var timestamp = log_line[1];
                var log_thing = log_line[2];
                switch (type) {
                    case "code":
                        output_str = output_str + timestamp_format(timestamp) + "system message: " + const_code[log_thing] + "\n";
                        break;
                    case "lua_print":
                        output_str = output_str + timestamp_format(timestamp) + "lua print: " + log_thing + "\n";
                        break;
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

var websocket_status_bt_on_click = function () {
    disable_all_bt();
    if (ws) {
        ws = false;
        WSocket.close();
        change_socket_status();
        refresh_bt_on_click();
    } else {
        ws_connect($('#websocket_uuid').val());
    }
}

var ws_connect = function (uuid) {
    WSocket.connect(websocket_url, appid, uuid, {
        on_open: function (socket) {
            //socket.send({
            //    socket_test_message: "hello world"
            //});
            ws = true;
            change_socket_status();
            refresh_bt_on_click();
            client_log("socket connect!!");
        },
        on_error: function (errorMsg) {
            client_log("socket error: " + errorMsg);
        },
        on_close: function (closeCode, closeReason) {
            ws = false;
            change_socket_status();
            refresh_bt_on_click();
            client_log("socket close: code[" + closeCode + "] " + closeReason)
        },
        on_message: function (socket, msgObj) {
            client_log(JSON.stringify(msgObj));
        }
    });
}

function client_log(v) {
    var old = $('#client_log').text();
    $('#client_log').text("[" + new Date().toLocaleString() + "]" + v + "\n" + old);
}

function clear_client_log() {
    $('#client_log').text("");
}