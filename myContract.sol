pragma solidity ^0.4.21;

contract MyContract {
    // 收据信息
    struct Receipt {   
        string from;    // 欠款人
        string to;      // 收款人
        uint mount;     // 金额
        string status;  // 状态，是否被银行确认
    }

    // 公司信息
	struct Company {
		string name;    // 公司名称
        string addr;    // 公司地址
        string type;    // 公司类型
        mapping(string=>Receipt) receipts_from;   // 作为欠款人的收据
        mapping(string=>Receipt) receipts_to;     // 作为收款人的收据
	}

    mapping(string=>Company) companies;


    function generateReceipt(string from, string to, uint mount) returns (Receipt recpt) {
        if (companies[from] == 0) {
            tmp = new Company(from);
            companies[from] = tmp;
        }
        if (companies[to] == 0) {
            tmp = new Company(to);
            companies[to] = tmp;
        }

        recpt = new Receipt(from, to, mount, "unconfirmed");
        companies[from].receipts_from[from] = recpt;
        companies[to].receipts_to[to] = recpt;

        return recpt;
    }

    function 


}
