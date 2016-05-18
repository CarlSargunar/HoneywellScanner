var exec = require("cordova/exec");

function HoneywellScanner() {
};

HoneywellScanner.prototype.enable = function(successCallback, errorCallback, onScan) {
    var noOnScan = !onScan;
    if (noOnScan) { onScan = successCallback; }

    var handleCallback = function(result) {
      var data = JSON.parse(result);

      if(data.status && noOnScan) {
        if (data.status === 'CONNECTED') {
          successCallback();
        }
      } else if (data.status) {
          switch(data.status) {
          case "CONNECTED":
            successCallback(data.status);
            break;

          default:
            errorCallback("Captuvo is Not Connected");
          }
      }
      else if (data.data) {
        onScan(data.data);
      }
    }

    exec(handleCallback,null,'HoneywellScanner','registerCallback',[]);
  };

HoneywellScanner.prototype.disable = function() {
  delete cordova._captuvoCallback;
  exec(null, null, 'HoneywellScanner', 'disable', [] );
};

HoneywellScanner.prototype.trigger = function() {
  exec(null, null, 'HoneywellScanner', 'trigger', [] );
};

// exports
var plugin = new HoneywellScanner();
module.exports = plugin;
