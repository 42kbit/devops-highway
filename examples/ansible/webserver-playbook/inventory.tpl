# This file is auto generated by main.tf, try not to edit it.

%{ for con in cons ~}
%{ for group in con.ansible_groups ~} [${group}]
${con.ip} %{ for arg in con.args ~} ${arg} %{endfor ~}

%{endfor ~}
%{ endfor ~}