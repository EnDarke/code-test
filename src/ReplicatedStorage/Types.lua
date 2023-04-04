export type Module = {
    [any]: any | (any) -> (any);
}

export type PlayerData = {
    Core: {
        Money: number;
        Paycheck: number;
        PaycheckWithdrawalAmount: number;
        PadsPurchased: {};
    },
}

export type PaycheckMachine = {
    DisplayName: StringValue,
    Money_Info_Text: Instance,
}

return {}