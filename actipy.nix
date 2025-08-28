{
pkgs, forEachSupportedSystem

}:{
    pname = "actipy";
    version = "3.7.0";
    pyproject = true;
    src = pkgs.fetchPypi {
      inherit pname version;
      format = "wheel";
      python = "py3";
      dist = "py3";
      abi = "none";
      platform = "any";
      # sha256 (SRI) or base32 works:
      hash = "sha256-ZDg5scRuk+SXvrledB1A3VhfxOSJpEwsbOiahpqc72c="; # <-- SRI works if you use 'hash'
    };
    doCheck = false;


  };


}

