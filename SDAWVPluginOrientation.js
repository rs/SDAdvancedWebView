/**
 * This class provides access to the device orientation.
 * @constructor
 */
function Orientation()
{
	/**
	 * The current orientation, or null if the orientation hasn't changed yet.
	 */
	this.currentOrientation = null;

    this.init = function()
    {
        this._notifyCurrentOrientation(this.currentOrientation);
    }

    this.shouldAutorotateToContentOrientation = function(orientation)
    {
        return orientation == 0;
    }

    this._notifyCurrentOrientation = function(orientation)
    {
        if (document != null && document.body != null)
        {
            // swap portrait/landscape class on the body element
            portrait = orientation == 0 || orientation == 180;
            document.body.className = document.body.className.replace(/(?:^| +)(?:portrait|landscape)(?: +|$)/g, " ")
                                      + " " + (portrait ? "portrait" : "landscape");

            if (this.currentOrientation != null && this.currentOrientation != orientation)
            {
                var event = document.createEvent('Events');
                event.initEvent('orientationchange', true);
                document.dispatchEvent(event);
            }
        }

        this.currentOrientation = orientation;
    }

    this.setContentOrientation = function(orientation)
    {
        navigator.comcenter.exec("Orientation.setContentOrientation", orientation);
    }
}

SDAdvancedWebViewObjects['orientation'] = new Orientation();
