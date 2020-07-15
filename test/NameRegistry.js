const {expectRevert} = require("openzeppelin-test-helpers");

const NameRegistry = artifacts.require('NameRegistry');


let name1 = web3.utils.utf8ToHex('Hello world!');
let name2 = web3.utils.utf8ToHex('World hello!');
let name3 = web3.utils.utf8ToHex('Hulahup!');


contract("NameRegistry", async (accounts) => {
    let nameRegistry;

    before(async () => {
        nameRegistry = await NameRegistry.new({from: accounts[0]});
    });

    it('sets name', async function() {

        await nameRegistry.setName(name1, {from: accounts[1]});

        assert.equal(await nameRegistry.getName(accounts[1]), name1);
        assert.equal(await nameRegistry.getAddress(name1), accounts[1]);
    });

    it('edits name', async function() {

        await nameRegistry.setName(name2, {from: accounts[1]});

        assert.equal(await nameRegistry.getName(accounts[1]), name2);
        assert.equal(await nameRegistry.getAddress(name2), accounts[1]);
    });

    it('should fail, if another address tries to set the same name', async function() {

        await expectRevert(
            nameRegistry.setName(name2, {from: accounts[2]}),
            "Only the initial setter can edit this name"
        );
    });

    it('should give the right count', async function() {
        assert.equal(await nameRegistry.length(), '1');

        // add new entry
        await nameRegistry.setName(name3, {from: accounts[3]});

        assert.equal(await nameRegistry.length(), '2');
    });


    it('should give the right values at indexes', async function() {
        let getIndex0 = await nameRegistry.atIndex(0);
        let getIndex1 = await nameRegistry.atIndex(1);

        assert.equal(getIndex0.setter, accounts[1]);
        assert.equal(getIndex0.name, name2);

        assert.equal(getIndex1.setter, accounts[3]);
        assert.equal(getIndex1.name, name3);

    });

    it('should contain name2, name3, but not name1', async function() {
        assert.isTrue(await nameRegistry.containsName(name2));
        assert.isTrue(await nameRegistry.containsName(name3));
        assert.isFalse(await nameRegistry.containsName(name1));
    });

    it('should contain address 1 and 3, but not 2', async function() {
        assert.isTrue(await nameRegistry.containsAddress(accounts[1]));
        assert.isTrue(await nameRegistry.containsAddress(accounts[3]));
        assert.isFalse(await nameRegistry.containsAddress(accounts[2]));
    });

});
