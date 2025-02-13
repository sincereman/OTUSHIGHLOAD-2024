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
%{ for index, name in nodeelk_name ~}
${name}-web: ${nodeelk_internal_ip_web[index]}
${name}-db: ${nodeelk_internal_ip_db[index]} 
%{ endfor ~}
%{ for index, name in nodeprom_name ~}
${name}-web: ${nodeprom_internal_ip_web[index]}
${name}-db: ${nodeprom_internal_ip_db[index]} 
%{ endfor ~}
%{ for index, name in nodedb_name ~}
${name}-db: ${nodedb_internal_ip_db[index]} 
%{ endfor ~}
%{ for index, name in nodeelk_name ~}
${name}-web: ${nodeelk_internal_ip_web[index]}
${name}-db: ${nodeelk_internal_ip_db[index]} 
%{ endfor ~}
%{ for index, name in nodebackup_name ~}
${name}-web: ${nodeelk_internal_ip_web[index]}
${name}-db: ${nodeelk_internal_ip_db[index]} 
%{ endfor ~}