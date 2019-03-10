int deobfuscation(char *from, char *to);

int key[4] = {0x58,0x17,0x7a,0x70};
char input[30] = { 0xd8, 0xfa, 0x95, 0x93, 0xf6, 0xf2, 0x8c, 0x99, 0xaa, 0xf3, 0x9b, 0xde, 0xa8, 0xe3, 0x9c};

int main(int argc, char **argv) {

	char *output = (char*)malloc(15 * sizeof(char));
	deobfuscation(input,output);
	printf(output);

	return 0;
}


// deobfuscation method
int deobfuscation(char *from, char *to) {
	
	// find last element of input char array
	int cnt= 0;
	
	while (from[cnt] != 0)
		cnt++;
         
	int reverseCnt = cnt - 1;
 
	cnt = 0;

	// from last to first element of input char array
	// deobfuscate and add to output array
	while (reverseCnt > 0) {
		char readvalue = from[reverseCnt];
  
		// produces index number 0<=i<=3
		int index = reverseCnt & 0x80000003;

		if (index < 0)
			index = ((index - 1) | -3) + 1;

		// deobfuscate value
		char deobfvalue = ((readvalue ^ key[index]) & 0x7F);
		
		to[cnt] = deobfvalue;
		reverseCnt--;
		cnt++;
	}
	return 1;
}




