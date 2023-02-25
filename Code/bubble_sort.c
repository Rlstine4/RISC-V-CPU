
void main()

{
    int arr[] = {40, 89, 5, 74, 1};

    int temp = 0;
    //int size = sizeof(arr) / sizeof(arr[0]);

    for (int i = 0; i <= 3; i++)
    {
        for (int j = 0; j <= 3 - i; j++)
        {
            if (arr[j] > arr[j+1]) 
            {
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }

}
