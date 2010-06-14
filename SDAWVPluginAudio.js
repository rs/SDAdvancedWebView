function AudioOptions()
{
    /**
     * The number of times a sound will return to the beginning, upon reaching the end, to repeat playback.
     *
     * A value of 0, which is the default, means to play the sound once. Set a positive integer value to specify
     * the number of times to return to the start and play again. For example, specifying a value of 1 results
     * in a total of two plays of the sound. Set any negative integer value to loop the sound indefinitely until
     * you call the stop method.
     */
    this.numberOfLoops = 0;
}

function Audio()
{
    this.playing = false;

    this._onSuccessCallback = function() {}
    this._onErrorCallback = function() {}

    this._onPlayingStateChange = function(playing)
    {
        this.playing = playing;
    }

    /**
     * Load the sound file at the given URL and prepare for playing.
     *
     * @param url URL of the sound file to load. As the sound is played in memory, sound file size is limited to 1MB.
     * @param onSuccessCallback function called when the
     */
    this.load = function(url, onSuccessCallback, onErrorCallback)
    {
        this._onSuccessCallback = onSuccessCallback;
        this._onErrorCallback = onErrorCallback;
        navigator.comcenter.exec("Audio.load", url);
    }

    /**
     * Plays the previousely loaded sound file.
     *
     * @param numberOfLoops
     * A value of 0, which is the default, means to play the sound once. Set a positive integer value to specify
     * the number of times to return to the start and play again. For example, specifying a value of 1 results
     * in a total of two plays of the sound. Set any negative integer value to loop the sound indefinitely until
     * you call the stop method.
     */
    this.play = function(numberOfLoops)
    {
        navigator.comcenter.exec("Audio.play", numberOfLoops);
    }

    this.pause = function()
    {
        navigator.comcenter.exec("Audio.pause");
    }

    this.stop = function()
    {
        navigator.comcenter.exec("Audio.stop");
    }
}

SDAdvancedWebViewObjects['audio'] = new Audio();
