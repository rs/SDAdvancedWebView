//
// This code is highly inspired from the PhoneGap project
//

function SDAdvancedWebViewComCenter()
{
    this.queue =
    {
        ready: true,
        commands: [],
        timer: null
    };

    // List of methods to call while comcenter has finish loading
    this.constructors = [];

    /**
     * Add an initialization function to a queue that ensures it will run and initialize
     * application constructors only once comcenter has been initialized.
     * @param {Function} func The function callback you want run once comcenter is initialized
     */
    this.addConstructor = function(func)
    {
        var state = document.readyState;
        if (state == 'loaded' || state == 'complete')
        {
            func();
        }
        else
        {
            this.constructors.push(func);
        }
    }

    /**
     * Execute commands in a queued fashion, to ensure commands do not
     * execute with any race conditions, and only run when comcenter is ready to
     * recieve them.
     * @param {String} command Command to be run, e.g. "ClassName.method"
     * @param {String[]} [args] Zero or more arguments to pass to the method
     * @param {Object} an optional dictionnary e.g. {"arg1": "value1", "arg2", "value2"}
     */
    this.exec = function()
    {
        this.queue.commands.push(arguments);
        if (this.queue.timer == null)
        {
            var self = this;
            this.queue.timer = setInterval(function() {self.runCommand()}, 10);
        }
    }

    /**
     * Internal function used to dispatch the request back to UIWebView. It processes the
     * command queue and executes the next command on the list.  If one of the
     * arguments is a JavaScript object, it will be passed on the QueryString of the
     * url, which will be turned into a dictionary on the other end.
     * @private
     */
    this.runCommand = function()
    {
        if (!this.queue.ready)
        {
            return;
        }

        this.queue.ready = false;

        var args = this.queue.commands.shift();
        if (this.queue.commands.length == 0)
        {
            clearInterval(this.queue.timer);
            this.queue.timer = null;
        }

        var command = args[0];
        var path = [];
        var options = '';
        var last_arg_idx = args.length - 1;

        if (args.length > 1 && typeof(args[args.length - 1]) == 'object')
        {
            last_arg_idx--;
            var dict = args[args.length - 1];
            var components = [];
            for (var name in dict)
            {
                if (typeof(name) != 'string')
                {
                    continue;
                }
                components.push(encodeURIComponent(name) + "=" + encodeURIComponent(dict[name]));
            }
            if (components.length > 0)
            {
                options = '?' + components.join("&");
            }
        }

        for (var i = 1; i <= last_arg_idx; i++)
        {
            var arg = args[i];
            if (arg == undefined || arg == null)
            {
                arg = '';
            }
            path.push(encodeURIComponent(arg));
        }

        document.location = "comcenter://" + command + "/" + path.join("/") + options;
    }
}

SDAdvancedWebViewObjects =
{
    'comcenter': new SDAdvancedWebViewComCenter()
};

(function()
{
    var timer = setInterval(function()
    {
        var state = document.readyState;

        if ((state == 'loaded' || state == 'complete'))
        {
            clearInterval(timer); // stop looking

            for (var name in SDAdvancedWebViewObjects)
            {
                navigator[name] = SDAdvancedWebViewObjects[name];
                if (navigator[name].init != null)
                {
                    navigator[name].init();
                }
            }

            var event = document.createEvent('Events');
            event.initEvent('deviceready');
            document.dispatchEvent(event);
        }
    }, 1);
})();
