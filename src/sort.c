////////////////
// v0.1 bubble sort
// 2019-08-26
// by Zhengfan Xia
////////////////


int bsort(int *array, int n){
	int temp;
	for(int i=0;i<n;i++) 
		for(int j=i;j<n;j++) 
			if(array[i]>array[j]) {
				temp = array[j];
				array[j] = array[i];
				array[i] = temp;
			}

	return 1;
}

void merge(int *array, int n, int l, int m){
	int p1 = l-n+1;
	int p2 = m-l;
	int i,j,k;
	int L[p1];
	int R[p2];
	for(i=0;i<p1;i++) L[i] = array[n+i];
	for(i=0;i<p1;i++) R[i] = array[l+1+i];
	i=0;j=0;k=n;
	while(i<p1 && j<p2) {
		if(L[i]>R[j]) {
			array[k] = R[j];
			j++;k++;
		} else {
			array[k] = L[i];
			i++;k++;
		} 
	}
	while(i<p1) {
		array[k] = L[i];
		i++;k++;
	}
	while(j<p2) {
		array[k] = R[j];
		j++;k++;
	}
}

int msort(int *array, int n, int m){

	if(m>n) {
		int l=n+(m-n)/2;
		msort(array,n,l);
		msort(array,l+1,m);
		merge(array,n,l,m);
	}

	return 1;
}
