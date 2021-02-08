<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE HTML>
<html>
<head>
    <meta charset="UTF-8">
    <title>OpenSheetMusicDisplay Test2</title>
    <meta name=viewport content="width=device-width,initial-scale=1">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
    <style>
        main {
            width: 1400px;
            max-width: 90%;
            margin: 40px auto 20px auto;
        }
    </style>
</head>
<body>
<main>
    <div class="controls">
        <button id="btn-play">Play</button>
        <button id="btn-pause">Pause</button>
        <button id="btn-stop">Stop</button>
        <button id="btn-zoom-in">ZoomIn</button>
        <button id="btn-zoom-out">ZoomOut</button>
        <button id="btn-test1">Test1</button>
        <button id="btn-test2">Test2</button>
    </div>
    <div>
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
    let prevMousePoint = null;

    $(document).ready(function () {
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
        });
    });

    async function loadScore(url, callback)
    {
        osmd = new opensheetmusicdisplay.OpenSheetMusicDisplay(document.getElementById("score"));
        audioPlayer = new OsmdAudioPlayer();

        const scoreXml = await fetch(url)
            .then(r => r.text());

        // console.log("Score xml: ", scoreXml);

        await osmd.load(scoreXml);
        await osmd.render();
        await audioPlayer.loadScore(osmd);
        audioPlayer.on("iteration", notes => {
            console.log(notes);
        });

        if (typeof callback === 'function')
            callback(true);
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
        el.addEventListener('mousedown', touchHandlerStart, false);
        el.addEventListener('mousemove', touchHandlerMove, false);
        el.addEventListener('mouseup', touchHandlerEnd, false);
        el.addEventListener('mouseleave', touchHandlerCancel, false);

        el.addEventListener('mousewheel', onMouseWheel, false);
    }

    document.getElementById('btn-zoom-in').addEventListener("click", function() {
        var svg = document.getElementById('osmdSvgPage1');
        var vb = svg.getAttribute("viewBox");
        //alert(vb);
        var vbParts = vb.split(' ');
        var minX = parseFloat(vbParts[0]);
        var minY = parseFloat(vbParts[1]);
        var width = +vbParts[2];
        var height = +vbParts[3];

        minX += 100.0;
        minY += 100.0;
        width -= 200.0;
        height -= 200.0;

        vb = minX + ' ' + minY + ' ' + width + ' ' + height;
        //alert(vb);
        svg.setAttribute("viewBox", vb);
    });

    document.getElementById('btn-zoom-out').addEventListener("click", function() {
        var svg = document.getElementById('osmdSvgPage1');
        var vb = svg.getAttribute("viewBox");
        //alert(vb);
        var vbParts = vb.split(' ');
        var minX = parseFloat(vbParts[0]) - 100;
        var minY = parseFloat(vbParts[1]) - 100;
        var width = parseFloat(vbParts[2]) + 200;
        var height = parseFloat(vbParts[3]) + 200;

        vb = minX + ' ' + minY + ' ' + width + ' ' + height;
        //alert(vb);
        svg.setAttribute("viewBox", vb);
    });

    $('#btn-test1').click(function () {
        // offsetHeight는 'undefined'가 나오고
        // clientHeight와 scrollHeight는 동일한 값이 나오네
        var svg = document.getElementById('osmdSvgPage1');
        console.log('offsetHeight: ' + svg.offsetHeight + ', clientHeight: ' + svg.clientHeight + ', scrollHeight: ' + svg.scrollHeight);
    });

    $('#btn-test2').click(function () {

    });

    let mouseX = -1;
    let mouseY = -1;
    let prevOffsetX = 0;
    let prevOffsetY = 0;

    function touchHandlerStart(e)
    {
        mouseX = e.clientX;
        mouseY = e.clientY;

        console.log('touchstart: ' + mouseX + ', ' + mouseY);

        prevMatrix = svg.getScreenCTM();
        prevOffsetX = viewBox.x;
        prevOffsetY = viewBox.y;
    }

    function touchHandlerMove(e)
    {
        if (e.which === 1)
        {
            if (mouseX < 0 || mouseY < 0)
            {
                mouseX = e.clientX;
                mouseY = e.clientY;
            }
            else
            {
                point.x = (mouseX - e.clientX) / prevMatrix.a;
                point.y = (mouseY - e.clientY) / prevMatrix.d;

                viewBox.x = prevOffsetX + point.x;
                viewBox.y = prevOffsetY + point.y;
            }

            console.log('touchmove: ');
        }
    }

    function touchHandlerEnd(e)
    {
        mouseX = -1;
        mouseY = -1;
        console.log('touchend: ');
    }

    function touchHandlerCancel(e)
    {
        mouseX = -1;
        mouseY = -1;
        console.log('touchcancel: ');
    }

    function onMouseWheel(event)
    {
        event.preventDefault();

        let normalized = 0;
        let delta = event.wheelDelta;

        if (delta) {
            normalized = (delta % 120) == 0 ? delta / 120 : delta / 12;
        } else {
            delta = event.deltaY || event.detail || 0;
            normalized = -(delta % 3 ? delta * 10 : delta / 3);
        }

        let scaleDelta = normalized > 0 ? 1 / 1.6 : 1.6;

        point.x = event.clientX;
        point.y = event.clientY;

        let startPoint = point.matrixTransform(svg.getScreenCTM().inverse());

        viewBox.x -= (startPoint.x - viewBox.x) * (scaleDelta - 1);
        viewBox.y -= (startPoint.y - viewBox.y) * (scaleDelta - 1);
        viewBox.width *= scaleDelta;
        viewBox.height *= scaleDelta;
    }

</script>
</body>
</html>
