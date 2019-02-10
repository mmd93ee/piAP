  function FindProxyForURL(url, host) {
        if (
            isInNet(myIpAddress(), "127.0.0.0", "255.0.0.0") ||
            isInNet(myIpAddress(), "192.168.0.0", "255.255.255.0")) {
            return "DIRECT";
        } else {
            return "PROXY 192.168.0.99:3128" ;
        }
    }
