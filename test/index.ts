import {expect} from "chai";
import {ethers} from "hardhat";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/src/signers";

describe("Guess Number", function () {


    let GuessNumber;


    let host;
    let player1;
    let player2;
    beforeEach(async () => {
            [host, player1, player2] = await ethers.getSigners();
            GuessNumber = await ethers.getContractFactory("GuessNumber", host);
        }
    );
    it("Case 1", async function () {
        const guessNumber = await GuessNumber.deploy("Hello", 999, player1.address, player2.address, {value: ethers.utils.parseEther("1")});
        await guessNumber.deployed();
        await guessNumber.connect(player1).guess(800,{
            value: ethers.utils.parseEther("1")
        });
        await guessNumber.connect(player2).guess(900,{
            value: ethers.utils.parseEther("1")
        });

        let beforeBal = await player2.getBalance();
        await guessNumber.connect(host).reveal("Hello",999);
        expect(await player2.getBalance()).to.equal(beforeBal.add(ethers.utils.parseEther("3")));
    });
    it("Case 2", async function () {
        const guessNumber = await GuessNumber.deploy("Hello", 999, player1.address, player2.address, {value: ethers.utils.parseEther("1")});
        await guessNumber.deployed();
        expect(guessNumber.connect(player1).guess(800,{
            value: ethers.utils.parseEther("2")
        })).to.be.revertedWith("The Player has not attached the same Ether value as the Host deposited.");
    });
    it("Case 3", async function () {
        const guessNumber = await GuessNumber.deploy("Hello", 500, player1.address, player2.address, {value: ethers.utils.parseEther("1")});
        await guessNumber.deployed();
        await guessNumber.connect(player1).guess(450,{
            value: ethers.utils.parseEther("1")
        });
        await guessNumber.connect(player2).guess(550,{
            value: ethers.utils.parseEther("1")
        });
        let player1Balance = await player1.getBalance();
        let player2Balance = await player2.getBalance();
        await guessNumber.connect(host).reveal("Hello",500);
        expect(await player1.getBalance()).to.equal(player1Balance.add(ethers.utils.parseEther("1.5")));
        expect(await player2.getBalance()).to.equal(player2Balance.add(ethers.utils.parseEther("1.5")));
    });

    it("Case 4", async function () {
        const guessNumber = await GuessNumber.deploy("Hello", 1415, player1.address, player2.address, {value: ethers.utils.parseEther("1")});
        await guessNumber.deployed();
        await guessNumber.connect(player1).guess(1,{
            value: ethers.utils.parseEther("1")
        });
        await guessNumber.connect(player2).guess(2,{
            value: ethers.utils.parseEther("1")
        });
        let player1Balance = await player1.getBalance();
        let player2Balance = await player2.getBalance();
        await guessNumber.connect(host).reveal("Hello",1415);
        expect(await player1.getBalance()).to.equal(player1Balance.add(ethers.utils.parseEther("1.5")));
        expect(await player2.getBalance()).to.equal(player2Balance.add(ethers.utils.parseEther("1.5")));
    });
});
