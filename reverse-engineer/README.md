# Reverse Engineer Windows executable

Using IDA (Interactive Disassembler) we extract the 8086 Assembly code of the executable file. 
The IDA creates the method calls diagram for the executable.

There are 3 method calls in our main function:

- BOOL WINAPI DeleteFile(_In_ LPCTSTR lpFileName) 
- Sub_401000 (Deobfuscation method)
- Sub_401090 (Connect and get file method)

The first method is a Windows API method, while the other two are the black-box methods to analyze.

## Black-box methods analysis

### Deobfuscation method

The method sub_401000 is called 4 times in the main method, with different parameters passed in the stack:
unk40E000, szServerName
unk40E100, szUserName
unk40E200, szPassword
unk40E300, szRemoteFile

Those parameters are passed as offsets to memory locations in the .data section of the program. 
The memory locations unk40* are arrays of random data, while the sz* ones are empty. 
When the method sub_401000 is executed, the sz* memory locations are populated with data.

Using static and dynamic code analysis, we figure out the methods functinality:
- Loads the consecutive bytes from the input address (argument 1) until it finds value 0
- De-obfuscates the read value using a de-obfuscation algorithm
- Populates the bytes of the output address (argument 2) with the de-obfuscated values

### Algorithm

In order to figure out how the deobfuscation algorithm works, we notice that:
- It counts the number of elements from the first address until it finds the value 0. For all the input addresses we notice that the first 0 byte is after 0xFF non-zero bytes. Therefore, the size of those arrays is 0xFF. The four arrays deobfuscated are stored in the memory addresses: unk40E000- unk40E0FF, unk40E100- unk40E1FF, unk40E200- unk40E2FF and unk40E300- unk40E3FF.
- Starting from the last element, it reads all the values. In order to deobfuscate, it calculates a value which is dependent to the position of the element. Using logical AND between the position of the element and the hex value 0x80000003, it calculates a value n which is 0<=n<=3 or indicates the last value of the array. Then it goes to the array which starts in memory address byte40e300 and takes the n-th element of it. Afterwards it uses this value to perform some more logical operations and calculate the deobfuscated data.
- Every deobfuscated value is stored in the the output array, starting from the beginning, and leaving always 1 byte empty. This is due to Ascii values being saved as 2 bytes. We end up with an array twice as big as the input array with reversed deobfuscated data.

The de-obfuscated values are passed as parameters using the stack in the second black-box method of the diagram sub_401090. 
The memory addresses unk40f860, unk40fc60, fileName and unk410260 are also passed to the method.

### Connect and get file method

The method sub_401090 uses some main Windows API methods. Its functionality is:

- Opens an Internet Connection to the FTP server given as parm, using the credentials given as parm
- Downloads a file from the FTP server
- Reads the contents of the file and populates the corresponding output byte arrays with those

```
HINTERNET InternetConnect(_In_ HINTERNET     hInternet, _In_ LPCTSTR       lpszServerName, _In_ INTERNET_PORT nServerPort, _In_ LPCTSTR       lpszUsername, _In_ LPCTSTR       lpszPassword, _In_ DWORD         dwService, _In_ DWORD         dwFlags, _In_ DWORD_PTR     dwContext);
Opens an File Transfer Protocol (FTP) or HTTP session for a given site.
```

```
HINTERNET InternetOpen(_In_ LPCTSTR lpszAgent, _In_ DWORD   dwAccessType, _In_ LPCTSTR lpszProxyName, _In_ LPCTSTR lpszProxyBypass, _In_ DWORD   dwFlags);
Initializes an application's use of the WinINet functions.
```

```
BOOL FtpGetFile(_In_ HINTERNET hConnect, _In_ LPCTSTR   lpszRemoteFile, _In_ LPCTSTR   lpszNewFile, _In_ BOOL      fFailIfExists, _In_ DWORD     dwFlagsAndAttributes, _In_ DWORD     dwFlags, _In_ DWORD_PTR dwContext);
Retrieves a file from the FTP server and stores it under the specified file name, creating a new local file in the process.
```

```
DWORD InternetAttemptConnect(_In_ DWORD dwReserved);
Attempts to make a connection to the Internet.
BOOL InternetCloseHandle(_In_ HINTERNET hInternet);
Closes a single Internet handle.
```

After the method sub_401090 returns, the DeleteFileW is called which deletes a file given as a parm. 
The parm fileName is populated from sub_401090, when scanning the file downloaded from the SFTP server. 
