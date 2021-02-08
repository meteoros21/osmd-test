<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE HTML>
<html>
<head>
    <meta charset="UTF-8">
    <title>OpenSheetMusicDisplay Test2</title>
    <meta name=viewport content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
    <style>
        body {
            touch-action: none;
            height: 100%;
        }
        #score {
            touch-action: pan-y;
            background-color: cornsilk;
        }
        svg {
            touch-action: manipulation;
        }

        .loader-container {
            position: absolute;
            background-color: azure;
            opacity: 0.5;
            width: 100%;
            height: 100%;
            z-index: 999;
        }
        .loader {
            position: absolute;
            left: 50%;
            top: 50%;
            border: 16px solid #f3f3f3; /* Light grey */
            border-top: 16px solid #3498db; /* Blue */
            border-radius: 50%;
            width: 120px;
            height: 120px;
            margin: -76px 0 0 -76px;
            animation: spin 2s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
<div class="loader-container" style="display: none">
    <div class="loader"></div>
</div>
<main>
    <div class="controls">
        <button id="btn-play">Play</button>
        <button id="btn-pause">Pause</button>
        <button id="btn-stop">Stop</button>
        <button id="btn-test1">Z-In</button>
        <button id="btn-test2">Z-Out</button>
    </div>
    <div style="display: none">
        <h2 id="loading">Loading</h2>
    </div>
    <div id="score" style="width: 100%"></div>
</main>
<script src="https://cdn.jsdelivr.net/npm/opensheetmusicdisplay@0.8.5/build/opensheetmusicdisplay.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/osmd-audio-player/umd/OsmdAudioPlayer.min.js"></script>
<%--<script src="/js/app.js"></script>--%>
<script>
    let osmd = null;
    let audioPlayer = null;
    let svg = 0;

    let point = null;
    let viewBox = null;
    let prevMatrix = null;

    $(document).ready(function () {

        showWaitScreen();

        loadScore('/data/MuzioClementi_SonatinaOpus36No3_Part1.xml', function (result) {

            if (result === true)
            {
                hideLoadingMessage();
                registerButtonEvents(audioPlayer);

                svg = document.getElementById('osmdSvgPage1');
                viewBox = svg.viewBox.baseVal;

                point = svg.createSVGPoint();
                prevMousePoint = svg.createSVGPoint();
            }

            hideWaitScreen();
        });
    });

    async function loadScore(url, callback)
    {
        osmd = new opensheetmusicdisplay.OpenSheetMusicDisplay(document.getElementById("score"),
            {
                followCursor: true,
                disableCursor: false
            });

        audioPlayer = new OsmdAudioPlayer();

        const scoreXml = await fetch(url)
            .then(r => r.text());

        await osmd.load(scoreXml);
        osmd.Zoom = 0.5;
        await osmd.render();
        await audioPlayer.loadScore(osmd);
        audioPlayer.on("iteration", notes => {
            console.log(notes);
        });

        if (typeof callback === 'function')
            callback(true);
    }

    function showWaitScreen()
    {
        $('.loader-container').css('display', '');
    }

    function hideWaitScreen()
    {
        $('.loader-container').css('display', 'none');
    }

    function hideLoadingMessage()
    {
        document.getElementById("loading").style.display = "none";
    }

    function registerButtonEvents(audioPlayer)
    {
        document.getElementById("btn-play").addEventListener("click", () => {
            if (audioPlayer.state === "STOPPED" || audioPlayer.state === "PAUSED") {
                audioPlayer.play();
            }
        });
        document.getElementById("btn-pause").addEventListener("click", () => {
            if (audioPlayer.state === "PLAYING") {
                audioPlayer.pause();
            }
        });
        document.getElementById("btn-stop").addEventListener("click", () => {
            if (audioPlayer.state === "PLAYING" || audioPlayer.state === "PAUSED") {
                audioPlayer.stop();
            }
        });

        const el = document.getElementById('score');

        el.addEventListener('pointerdown', onPointerDown, false);
        el.addEventListener('pointermove', onPointerMove, false);

        el.addEventListener('pointerup', onPointerUp, false);
        el.addEventListener('pointercancel', onPointerCancel, false);
        el.addEventListener('pointerout', onPointerOut, false);
        el.addEventListener('pointerleave', onPointerLeave, false);
    }

    $('#btn-test1').click(function () {
        const zoom = osmd.zoom + 0.25;
        zoomRender(zoom);
    });

    $('#btn-test2').click(function () {
        const zoom = osmd.zoom - 0.25;
        zoomRender(zoom)
    });

    let evCache = [];
    let prevDiff = -1;

    function onPointerDown(ev)
    {
        ev.preventDefault();
        addEvent(ev);

        if (evCache.length == 2)
        {
            prevMatrix = svg.getScreenCTM();
        }
    }

    function onPointerMove(ev)
    {
        ev.preventDefault();

        // 터치 포인터가 하나인 경우(PAN - Scroll)
        if (evCache.length == 1)
        {
            // pointerdown 이벤트 없이 pointermove 이벤트가 들어온 경우
            if (hasEvent(ev) === false)
            {
                // 이벤트를 등록하고 돌아간다.
                addEvent(ev);
                return;
            }

            // 이전 이벤트 때 측정된 좌표와 현재 측정된 좌표의 차이를 구해 스크롤한다.
            let curDiff = evCache[0].clientY - ev.clientY;
            window.scroll(0, window.scrollY + curDiff);

            // 이벤트를 등록한다.
            addEvent(ev);
        }
        // 터치 포인터가 둘인 경우(Pinch Zoom)
        else if (evCache.length == 2)
        {
            addEvent(ev);

            //let curDiff = Math.abs(evCache[0].clientX - evCache[1].clientX);
            let curDiff = Math.hypot(evCache[0].clientX - evCache[1].clientX,
                evCache[0].clientY - evCache[1].clientY);

            if (prevDiff > 0)
            {
                // 중심의 좌표
                point.x = (evCache[0].clientX + evCache[1].clientX) / 2;
                point.y = (evCache[0].clientY + evCache[1].clientY) / 2;

                let startPoint = point.matrixTransform(prevMatrix.inverse());
                //let startPoint = point.matrixTransform(svg.getScreenCTM().inverse());
                let scale = 1;

                if (curDiff < prevDiff)
                {
                    //alert('a');
                    //scale = 1.05;
                    scale = prevDiff / curDiff;
                }
                else if (curDiff > prevDiff)
                {
                    //alert('b');
                    //scale = 1 / 1.05;
                    scale = prevDiff / curDiff;
                }

                viewBox.x -= (startPoint.x - viewBox.x) * (scale - 1);
                viewBox.y -= (startPoint.y - viewBox.y) * (scale - 1);
                viewBox.width *= scale;
                viewBox.height *= scale;
            }

            prevDiff = curDiff;
        }
    }

    function onPointerUp(ev)
    {
        ev.preventDefault();

        if (evCache.length == 2)
            checkZoom();

        removeEvent(ev);

        // If the number of pointers down is less than two then reset diff tracker
        if (evCache.length < 2) {
            prevDiff = -1;
        }
    }

    function onPointerCancel(ev)
    {
        ev.preventDefault();

        if (evCache.length == 2)
            checkZoom();

        removeEvent(ev);

        // If the number of pointers down is less than two then reset diff tracker
        if (evCache.length < 2) {
            prevDiff = -1;
        }
    }

    function onPointerOut(ev)
    {
        ev.preventDefault();

        if (evCache.length == 2)
            checkZoom();

        removeEvent(ev);

        // If the number of pointers down is less than two then reset diff tracker
        if (evCache.length < 2) {
            prevDiff = -1;
        }
    }

    function onPointerLeave(ev)
    {
        ev.preventDefault();

        if (evCache.length == 2)
            checkZoom();

        removeEvent(ev);

        // If the number of pointers down is less than two then reset diff tracker
        if (evCache.length < 2) {
            prevDiff = -1;
        }
    }

    function addEvent(ev)
    {
        let added = false;

        for (let i = 0; i < evCache.length; i++)
        {
            if (evCache[i].pointerId == ev.pointerId)
            {
                evCache[i] = ev;
                added = true;
            }
        }
        if (added === false)
            evCache.push(ev);

        $('#value1').text(evCache.length);
    }

    function removeEvent(ev) {
        // Remove this event from the target's cache
        for (var i = 0; i < evCache.length; i++) {
            if (evCache[i].pointerId == ev.pointerId) {
                evCache.splice(i, 1);
                break;
            }
        }
        $('#value1').text(evCache.length);
    }

    function hasEvent(ev)
    {
        for (let i = 0; i < evCache.length; i++)
        {
            if (evCache[i].pointerId == ev.pointerId)
            {
                return true;
            }
        }

        return false;
    }

    function checkZoom()
    {
        const zoom = osmd.zoom;
        const matrix = svg.getScreenCTM();
        if (zoom == matrix.a)
            return;

        const zoomNew = matrix.a;
        console.log('zoom: ' + zoom + ', zoom2: ' + matrix.a + ', zoomNew: ' + zoomNew);
        zoomRender(zoomNew);
    }


    async function zoomRender(zoom)
    {
        showWaitScreen();

        let promise = new Promise((resolve, reject) => {
            setTimeout(() => {
                osmd.zoom = zoom;
                osmd.render();

                hideWaitScreen();

                svg = document.getElementById('osmdSvgPage1');
                viewBox = svg.viewBox.baseVal;

                // 새로 랜더링 하고나면 기존 커서가 무효화 되므로 새로운 커서를 audioPlayer에 전달한다.
                audioPlayer.cursor = osmd.cursor;
                // 커서 위치를 처음으로 되돌린다.
                //osmd.cursor.reset();
                // 화면에 커서를 표시한다.
                //osmd.cursor.show();

            }, 150)
        });
    }

    window.visualViewport.addEventListener('resize', function (event) {
        console.log(event.target.scale);
    })

</script>
</body>
</html>
