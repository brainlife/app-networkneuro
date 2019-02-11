mkdir -p decimate
for file in $(ls surfaces);
do
    echo $file
    #1.0 means original
    mris_decimate -d 0.5 surfaces/$file decimate/$file
done

