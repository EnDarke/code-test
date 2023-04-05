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

export type TemporaryData = {
    Plot: number;
    Debounce: number;
}

export type Plot = {
    Taken: boolean;
    Owner: string;
}

export type PaycheckMachine = {
    DisplayName: StringValue;
    Money_Info_Text: Instance;
}

export type Pad = {
    Dependency: ObjectValue;
    Attributes: {
        DependentFinished: boolean;
        isEnabled: boolean;
        isFinished: boolean;
        Price: number;
        TargetName: string;
    };
}

return {}