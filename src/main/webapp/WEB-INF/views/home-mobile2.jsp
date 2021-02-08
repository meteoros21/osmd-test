<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE HTML>
<html>
<head>
    <meta charset="UTF-8">
    <title>OpenSheetMusicDisplay Test2</title>
    <meta name=viewport content="width=device-width,initial-scale=1.0,maximum-scale=2.0, user-scalable=yes">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
    <style>
    </style>
</head>
<body>
<main>
    <div class="controls">
        <button id="btn-play">Play</button>
        <button id="btn-pause">Pause</button>
        <button id="btn-stop">Stop</button>
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

        //osmd.FollowCursor(true);

        // audioPlayer.setBpm(120);

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

                const cursor = osmd.cursor;
                cursor.reset();
                cursor.show();

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

                const cursor = osmd.cursor;
                cursor.hide();

                audioPlayer.stop();
            }
        });
    }

    $('#btn-test1').click(function () {
        osmd.Zoom = 1.0;
        osmd.render();
        // offsetHeight는 'undefined'가 나오고
        // clientHeight와 scrollHeight는 동일한 값이 나오네
        var svg = document.getElementById('osmdSvgPage1');
        console.log('offsetHeight: ' + svg.offsetHeight + ', clientHeight: ' + svg.clientHeight + ', scrollHeight: ' + svg.scrollHeight);
    });

    $('#btn-test2').click(function () {
        //osmd.zoom = 0.5;
        osmd.Zoom = 0.5;
        osmd.render();
    });

    window.visualViewport.addEventListener('resize', function (event) {
        console.log(event.target.scale);
    })

</script>
</body>
</html>
