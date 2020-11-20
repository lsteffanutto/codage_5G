function [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, indice_c, indice_v_final)

indice_c = indice_c+1;
indice_v_final = indice_v_final +1;
c_to_v(indice_v_final,indice_c)=res_L_c_to_v;

end

