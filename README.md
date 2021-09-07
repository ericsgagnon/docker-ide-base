# docker-ide-base
A base image for ide's, etc.  

-  based on ericsgagnon/buildpack-deps-cuda, which mimics buildpack-deps from nvidia/cudagl  
-  uses s6-overlay for cmd and process supervision  
  -  user creation, env vars, intializations via scripts in /etc/cont-init.d/  
  -  persistent services/daemon's via script in /etc/services.d/
  -  finalizers (graceful service shutdown, etc.) via scripts in /etc/cont-finish.d/

Notes about using s6-overlay:  

-  avoiding /etc/fix-attrs.d/ - it's easier to fix attrs via scripts in /etc/cont-init.d/  

