function Shake()
{
    this._notifyShakeDetected = function()
    {
        var event = document.createEvent('Events');
        event.initEvent('shake', true);
        document.dispatchEvent(event);
    }

    this.startListener = function()
    {
        navigator.comcenter.exec("Shake.start");
    }

    this.stopListener = function()
    {
        navigator.comcenter.exec("Shake.stop");
    }
}

SDAdvancedWebViewObjects['shake'] = new Shake();
