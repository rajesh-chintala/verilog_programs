Note:
Pointer is the next location to be written.

# Simulation Results:
Write operation: 
When the positive edge of the clk comes, the wr_en is enabled, Then the data requested to be written will be stored where the pointer points, as there is Non blocking assignments (the data, pointer increment) the pointer gets incremented to point the next location.
The flag generation logic is taken as assign statements, hence the generation of flags happens at the same moment the clock comes as pointers got updated. As the pointer points to the next location to be written generation of flags happen in the same moment stopping the operation in the next clock edge after the corresponding read/write operation performed.
Here the full condition generated when the data written to the last location pointer by old value of wptr(as non blocking assignments), the pointer got updated in the nba region, in the next delta cycle of simulation full flag will be asserted indicated full condition. This prevents the  overriding of data even when the clock edge comes, there is no chance of passing the if condition, hence no extra data writtern
The same happens with the read operation.
<img width="1639" height="873" alt="image" src="https://github.com/user-attachments/assets/c1afeeba-6312-4338-a9bd-5ae096feeb80" />

Read Operation:  
<img width="1641" height="877" alt="image" src="https://github.com/user-attachments/assets/e5284baa-4c29-415b-9c9b-cf06e8cb7e43" />

Both Read and Write:
When both read and write operations enabled, Write operation performed but not the read operation at the same momemt. Because, when the clock edge arrives, the block sees the old value of empty flag, as the flag is held, it skips the read operation. When the write operation completed and pointer incremented in the same edge, then  the flag has been removed in the next delta cycle, but there would be no clock edge to trigger agian the read operation in the same cycle.
<img width="1644" height="882" alt="image" src="https://github.com/user-attachments/assets/c5d37b38-835a-4e82-8f7d-1574c5710d76" />

overall:
<img width="1648" height="878" alt="image" src="https://github.com/user-attachments/assets/591aba66-1780-4c3a-93a7-f429d0a741d9" />

