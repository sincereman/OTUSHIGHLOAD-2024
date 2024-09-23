---
# group vars

ip_address:
%{ for index, name in frontend_name ~}
${name}-web: ${frontend_internal_ip_web[index]} 
%{ endfor ~}
%{ for index, name in nodeweb_name ~}
${name}-web: ${nodeweb_internal_ip_web[index]}
${name}-db: ${nodeweb_internal_ip_db[index]} 
%{ endfor ~}
%{ for index, name in nodedb_name ~}
${name}-db: ${nodedb_internal_ip_db[index]} 
%{ endfor ~}
%{ for index, name in nodehaproxybackend_name ~}
${name}-db: ${nodehaproxybackend_internal_ip_db[index]} 
%{ endfor ~}
%{ for index, name in nodeetcdbackend_name ~}
${name}-db: ${nodeetcdbackend_internal_ip_db[index]} 
%{ endfor ~}