/*
    Structure for keeping information about image 
    and ease of passing it as argument
*/
typedef struct BMPImage {
    unsigned char *data;
    int width, height, channels;
} BMPImage;
