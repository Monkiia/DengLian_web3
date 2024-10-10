import time
import hashlib
## print that we are going to get 4 zeros
## start time

def calculate_time(expected_input):
    # print expected input
    print("Expected input top Hash: ", expected_input)
    start = time.time()
    username = "crazychat"
    nounce = 0
    # sha256
    while True:
        nounce += 1
        data = username + str(nounce)
        hash_value = hashlib.sha256(data.encode()).hexdigest()
        if hash_value[:len(expected_input)] == expected_input:
            break
    print("Nounce: ", nounce)
    print("Hash: ", hash_value)
    print("Time: ", time.time() - start)

calculate_time("0000")
calculate_time("00000")
calculate_time("000000")