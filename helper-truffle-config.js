const networkConfig = {
    sepolia: {
        chainId: "11155111",
        linkToken: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
        keyHash: "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c",
        vrfCoordinator: "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625",
        jobId: "ca98366cc7314957b8c012c72f05aeeb",
        fee: "100000000000000000"
    },
}

const developmentChains = ["sepolia"]

module.exports = {
    networkConfig,
    developmentChains,
}
