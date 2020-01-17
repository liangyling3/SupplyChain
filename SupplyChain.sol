pragma solidity ^0.4.22;

contract SupplyChain{
    //公司信息
    struct Company{
        address name;   //公司名称
        address addr;   //公司地址
        uint type;      //公司类型 0为核心企业 1为银行 2为中小企业
    }

    //收据信息
    struct Receipt {
        uint receiptID;         //单据ID
        address from;           //发起者地址
        address to;             //收款人地址
        uint mount;             //金额
        address prover;         //见证机构名称
        bool financinged;       //是否已融资
        bool settled;           //是否已结算（由核心公司）
        uint[] transferRecord;  //被转让记录，里面是用此receipt作为凭证的转账的receiptID
        uint leftValue;         //剩余金额，将收据用于融资、还款后的剩余金额
    }

    // 写入单据
    event NewReceipt(string ReceiptType, uint receiptID, address from, address to, uint amount, address prover, bool financinged, bool settled, uint[] transferRecord, uint leftValue);
    // 存储结构
    mapping(address => Company) public companies;
    Company[] public companiesInChain;
    Receipt[] public receipts;


    //功能一：实现采购商品—签发应收账款交易上链。
    function GenerateReceipt(address fromer, address receiver, address prover, uint amount) {
        //核心机构入链
        companiesInChain.push(Company(fromer, 0));
        companies[fromer] = companiesInChain[0];
        //见证方入链
        companiesInChain.push(Company(prover, 1));
        companies[prover] = companiesInChain[1];
        //收款方入链
        companiesInChain.push(Company(receiver, 2));
        companies[receiver] = companiesInChain[2];
        
        //单据入链
        receipts.length ++;
        uint index = receipts.length -1;
        receipts[index].receiptID = receipts.length;
        receipts[index].from = fromer;
        receipts[index].to = receiver;
        receipts[index].mount = amount;
        receipts[index].financinged = false;
        receipts[index].settled = false;
        receipts[index].prover = prover;
        receipts[index].leftValue = amount;

        //打印收据
        emit NewReceipt("new", receipts[index].receiptID, receipts[index].from, receipts[index].to, receipts[index].mount, receipts[index].prover, receipts[index].financinged, receipts[index].settled, receipts[index].transferRecord, receipts[index].leftValue);
        
    }

    //检查company是否在链上
    function InChain(address company) public view returns (bool) {
        bool isInChain = false;
        for (uint i = 0; i < companiesInChain.length; i++) {
            if (companiesInChain[i].addr == company) {
                isInChain = true;
                break;
            }
        }
        return isInChain;
    }


    //功能二：实现应收账款的转让上链
    function Transfer(address fromer, address receiver, uint amount, uint receiptID) {
        //检查收据没有被用来融资
        require(
            !receipts[receiptID].financinged,
            "This receipt has been used to financing."
        );
        //检查收据金额足够
        require(
            receipts[receiptID].leftValue >= amount,
            "This receipt's leftValue is not enough now."
        );

        //收款方入链
        if (!InChain(receiver)) {
            companiesInChain.push(Company(receiver, 2));
            companies[receiver] = companiesInChain[companiesInChain.length - 1];
        }

        //新收据入链
        receipts.length ++;
        uint index = receipts.length-1;
        receipts[index].receiptID = receipts.length;
        receipts[index].from = receipts[receiptID].to;
        receipts[index].to = receiver;
        receipts[index].mount = amount;
        receipts[index].financinged = false;
        receipts[index].settled = false;
        receipts[index].leftValue = amount;
        //打印新收据 
        emit NewReceipt("new", receipts[index].receiptID, receipts[index].from, receipts[index].to, receipts[index].mount, receipts[index].prover, receipts[index].financinged, receipts[index].settled, receipts[index].transferRecord, receipts[index].leftValue);


        //更新旧收据
        receipts[receiptID].transferRecord.push(receipts.length - 1);
        receipts[receiptID].leftValue -= amount;
        //打印旧收据
        emit NewReceipt("fresh", receiptID, receipts[receiptID].from, receipts[receiptID].to, receipts[receiptID].mount, receipts[receiptID].prover, receipts[receiptID].financinged, receipts[receiptID].settled, receipts[receiptID].transferRecord, receipts[receiptID].leftValue);

    }


    //功能三： 利用应收账款向银行融资上链
    function Financing(uint receiptID) {
        //检查收据没有被用来融资
        require(
            !receipts[receiptID].financinged,
            "This receipt has been used to financing."
        );
        // 更新收据
        receipts[receiptID].financinged = true;
        // 打印收据
        emit NewReceipt("fresh", receiptID, receipts[receiptID].from, receipts[receiptID].to, receipts[receiptID].mount, receipts[receiptID].prover, receipts[receiptID].financinged, receipts[receiptID].settled, receipts[receiptID].transferRecord, receipts[receiptID].leftValue);

    }


    //功能四：应收账款支付结算上链
    function Settle(uint receiptID) {
        // 更新收据
        receipts[receiptID].settled = true;
        // 打印收据
        emit NewReceipt("fresh", receiptID, receipts[receiptID].from, receipts[receiptID].to, receipts[receiptID].mount, receipts[receiptID].prover, receipts[receiptID].financinged, receipts[receiptID].settled, receipts[receiptID].transferRecord, receipts[receiptID].leftValue);

    }
}

