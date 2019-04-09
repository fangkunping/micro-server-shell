// SevenD.WSocket.connect("ws://192.168.1.55:5501/socket/websocket")
var WSocket = (function () {
    var ws;
    var callback_fn = {};
    var topic;
    var ref = 1;
    var CONST_JOIN_SUCCESS = 1;
    var HEART_BEAT = 30000;

    function is_supported() {
        return (typeof WebSocket !== "undefined")
    }

    function connect(uri, app_id, uuid) {
        topic = "ant:"+app_id;

        if (arguments.length > 3) {
            callback_fn = arguments[3];
        }
        if (!is_supported()) {
            return false;
        }
        if (ws) {
            ws.close();
        }
        //console.log(uri);
        var me = this;
        ws = new WebSocket(uri + "?appid=" + app_id + "&uuid=" + uuid);
        //ws.binaryType = "arraybuffer";
        ws.onopen = function () {
            me.send({uuid: uuid}, "phx_join");
        };
        ws.onerror = function (err_) {
            //console.log(err_);
            var errorMsg;
            if (typeof (err_) == 'string')
                errorMsg = err_;
            else
                errorMsg = (err_ && typeof (err_.data) == 'string' ? err_.data : "");
            if (callback_fn.hasOwnProperty('on_error')) {
                callback_fn.on_error(errorMsg);
            }
        };
        ws.onclose = function (e) {
            var closeCode = e["code"] || 0;
            var closeReason = e["reason"] || "";
            if (callback_fn.hasOwnProperty('on_close')) {
                callback_fn.on_close(closeCode, closeReason);
            }

        };
        ws.onmessage = function (msg_) {
            //console.log(msg_);

            var messageText = msg_.data || "";
            var msgJson = JSON.parse(messageText);
            //console.log(msgJson);
            switch (msgJson.event) {
                case "phx_reply":
                    // 只有在join后的返回才是真正的连接成功
                    if (msgJson.payload.status == "ok" && msgJson.payload.response == CONST_JOIN_SUCCESS) {
                        if (callback_fn.hasOwnProperty('on_open')) {
                            callback_fn.on_open(me);
                        }
                        //开启心跳
                        me.heartbeat();
                    }
                    break;
                case "phx_error":
                    me.close();
                    break;
                case "response":
                    if (callback_fn.hasOwnProperty('on_message')) {
                        callback_fn.on_message(me, msgJson.payload.message);
                    }
                    break;
            }

        };
        return true;
    }

    function send(msg_) {
        var event = "request";
        if (arguments.length > 1) {
            event = arguments[1];
        }
        if (!ws || ws.readyState !== 1 /* OPEN */ )
            return false;
        var sendData = JSON.stringify({
            topic: topic,
            event: event,
            "payload": msg_,
            ref: ref
        });
        ref++;
        console.log(sendData);
        ws.send(sendData);
        return true;
    }

    function close() {
        if (ws)
            ws.close();
    }

    function heartbeat() {
        if (send({}, "heartbeat")) {
            setTimeout("WSocket.heartbeat()", HEART_BEAT)
        }
    }
    return {
        is_supported: is_supported,
        connect: connect,
        send: send,
        close: close,
        heartbeat: heartbeat
    }
})();