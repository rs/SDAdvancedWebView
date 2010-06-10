//
// This code is highly inspired from the PhoneGap project
//

function Acceleration(x, y, z)
{
	this.x = x;
	this.y = y;
	this.z = z;
	this.timestamp = new Date().getTime();
}

function AccelerationOptions()
{
	/**
	 * The timeout after which if acceleration data cannot be obtained the errorCallback
	 * is called.
	 */
	this.timeout = 10000;
}


/**
 * This class provides access to device accelerometer data.
 * @constructor
 */
function Accelerometer()
{
	/**
	 * The last known acceleration.
	 */
	this.lastAcceleration = new Acceleration(0, 0, 0);

    // private callback called from Obj-C by name
    this._onAccelUpdate = function(x, y, z)
    {
        this.lastAcceleration = new Acceleration(x, y, z);
    }

    /**
     * Asynchronously aquires the current acceleration.
     * @param {Function} successCallback The function to call when the acceleration
     * data is available
     * @param {Function} errorCallback The function to call when there is an error
     * getting the acceleration data.
     * @param {AccelerationOptions} options The options for getting the accelerometer data
     * such as timeout.
     */
    this.getCurrentAcceleration = function(successCallback, errorCallback, options)
    {
        // If the acceleration is available then call success
        // If the acceleration is not available then call error

        // Created for iPhone, Iphone passes back _accel obj litteral
        if (typeof successCallback == "function")
        {
            successCallback(this.lastAcceleration);
        }
    }

    /**
     * Asynchronously aquires the acceleration repeatedly at a given interval.
     * @param {Function} successCallback The function to call each time the acceleration
     * data is available
     * @param {Function} errorCallback The function to call when there is an error
     * getting the acceleration data.
     * @param {AccelerationOptions} options The options for getting the accelerometer data
     * such as timeout.
     */
    this.watchAcceleration = function(successCallback, errorCallback, options)
    {
        //this.getCurrentAcceleration(successCallback, errorCallback, options);
        // TODO: add the interval id to a list so we can clear all watches
        var frequency = (options != undefined && options.frequency != undefined) ? options.frequency : 10000;
        var updatedOptions = {desiredFrequency: frequency};
        navigator.comcenter.exec("Accelerometer.start", options);

        var self = this;
        return setInterval(function() {self.getCurrentAcceleration(successCallback, errorCallback, options)}, frequency);
    }

    /**
     * Clears the specified accelerometer watch.
     * @param {String} watchId The ID of the watch returned from #watchAcceleration.
     */
    this.clearWatch = function(watchId)
    {
        navigator.comcenter.exec("Accelerometer.stop");
        clearInterval(watchId);
    }
}

if (typeof(navigator.accelerometer) == "undefined")
{
    navigator.accelerometer = new Accelerometer();
}


