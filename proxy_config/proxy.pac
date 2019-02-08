  function FindProxyForURL(url, host) {
        if (
            isInNet(myIpAddress(), "127.0.0.0", "255.0.0.0") ||
            isInNet(myIpAddress(), "192.168.0.0", "255.255.255.0")) {
            return "DIRECT";
        } else {
            if (shExpMatch(url, "http:*"))
                return "PROXY 192.168.0.99:3128" ;
            if (shExpMatch(url, "https:*"))
                return "PROXY 192.168.0.99:3128" ;
             if (shExpMatch(url, "ftp:*"))
                return "PROXY 192.168.0.99:3128" ;
             if (shExpMatch(url, "ftps:*"))
                return "PROXY 192.168.0.99:3128" ;
              if (shExpMatch(url, "sftp:*"))
                return "PROXY 192.168.0.99:3128" ;
            return "DIRECT";
        }
    }