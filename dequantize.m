function Dq = dequantize(matIn,Q_std)

Dq = round(matIn.*Q_std);

end