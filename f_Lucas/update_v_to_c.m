function [v_to_c] = update_v_to_c(v_to_c, res_L_v_to_c, indice_v, indice_c_final)

indice_v = indice_v+1;
indice_c_final = indice_c_final +1;
v_to_c(indice_c_final,indice_v)=res_L_v_to_c;

end

