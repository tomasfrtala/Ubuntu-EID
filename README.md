# Ubuntu 18.04 with EID 3.0.0
This is alternative installator to fix issue of contraindiction between libcurl3 and libcurl4 caused error with installing EID 3.0.0

## Run the installator
Open your terminal and just run it:
```
./fix.sh
```

## Starting the eid
You need to tell EID where to find the old libcurl3 therefore use:
```
env LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libcurl.so.3 EAC_MW_klient
```
The installator adds optional shortcut for this and you can start using it with:
```
eid
``` 
