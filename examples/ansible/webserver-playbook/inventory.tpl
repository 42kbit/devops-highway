%{ for con in cons ~}
${con.ip} %{ for arg in con.args ~} ${arg} %{endfor ~}

%{ endfor ~}