function Q = quantize(matIn,Q_std)

Q = round(matIn./Q_std);

end