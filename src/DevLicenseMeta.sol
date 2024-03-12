// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {DevLicenseLock} from "./DevLicenseLock.sol";

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract DevLicenseMeta is DevLicenseLock {

    string public _imageToken;
    string public _imageContract;
    string public _descriptionToken;
    string public _descriptionContract;

    constructor(
        address licenseAccountFactory_,
        address provider_,
        address dimoTokenAddress_, 
        address dimoCreditAddress_,
        uint256 licenseCostInUsd_) 
    DevLicenseLock(
        licenseAccountFactory_,
        provider_,
        dimoTokenAddress_, 
        dimoCreditAddress_,
        licenseCostInUsd_
    ) {
        string memory image = '<svg width="1872" height="1872" viewBox="0 0 1872 1872" fill="none" xmlns="http://www.w3.org/2000/svg"> <rect width="1872" height="1872" fill="#191919"/> <g clip-path="url(#clip0_736_195)"> <path fill-rule="evenodd" clip-rule="evenodd" d="M1344.86 1005.3C1365.39 1013.67 1387.4 1017.89 1409.59 1017.71C1431.78 1017.93 1453.8 1013.73 1474.35 1005.38C1494.9 997.017 1513.57 984.662 1529.26 969.034C1544.97 953.408 1557.37 934.818 1565.77 914.359C1574.17 893.898 1578.39 871.976 1578.17 849.874C1578.39 827.769 1574.17 805.844 1565.78 785.38C1557.38 764.916 1544.98 746.325 1529.28 730.694C1513.58 715.063 1494.91 702.706 1474.36 694.347C1453.8 685.987 1431.79 681.792 1409.59 682.008C1387.4 681.829 1365.4 686.048 1344.86 694.418C1324.33 702.789 1305.68 715.145 1289.99 730.765C1274.3 746.386 1261.89 764.959 1253.48 785.403C1245.07 805.846 1240.82 827.753 1241 849.845C1240.82 871.939 1245.06 893.848 1253.46 914.296C1261.87 934.743 1274.29 953.319 1289.98 968.943C1305.67 984.566 1324.32 996.926 1344.86 1005.3ZM1535.43 849.845C1535.43 921.18 1481.23 977.456 1409.59 977.456C1338.39 977.456 1284.19 921.211 1284.19 849.845C1284.19 778.478 1338.39 722.234 1409.59 722.234C1481.23 722.234 1535.43 778.508 1535.43 849.845Z" fill="white"/> <path d="M1155.64 1010.52H1199.46V753.502C1199.44 735.747 1192.34 718.726 1179.73 706.171C1167.13 693.616 1150.03 686.552 1132.2 686.529C1119.44 686.562 1106.95 690.196 1096.18 697.009C1085.4 703.821 1076.79 713.534 1071.33 725.021L967.306 945.486C965.402 949.488 962.401 952.873 958.645 955.249C954.889 957.623 950.536 958.889 946.089 958.904C943.009 958.904 939.962 958.302 937.117 957.128C934.274 955.956 931.689 954.235 929.512 952.069C927.338 949.899 925.61 947.327 924.432 944.497C923.254 941.664 922.649 938.63 922.649 935.563V775.229C922.624 751.711 913.231 729.164 896.53 712.534C879.83 695.905 857.187 686.552 833.568 686.529C809.956 686.56 787.322 695.916 770.626 712.545C753.934 729.173 744.543 751.716 744.52 775.229V1010.49H788.34V775.229C788.356 763.286 793.125 751.837 801.603 743.389C810.08 734.942 821.575 730.185 833.568 730.161C845.567 730.177 857.071 734.93 865.554 743.379C874.039 751.827 878.814 763.281 878.829 775.229V935.563C878.844 953.322 885.937 970.348 898.546 982.905C911.158 995.46 928.253 1002.52 946.089 1002.54C958.85 1002.51 971.343 998.876 982.115 992.063C992.888 985.247 1001.5 975.534 1006.96 964.045L1110.98 743.58C1112.89 739.579 1115.89 736.196 1119.65 733.822C1123.4 731.448 1127.75 730.179 1132.2 730.161C1138.41 730.169 1144.37 732.631 1148.77 737.006C1153.16 741.382 1155.63 747.314 1155.64 753.502V1010.52Z" fill="white"/> <path d="M643.066 686.676H685.535V1010.54H643.066V686.676Z" fill="white"/> <path fill-rule="evenodd" clip-rule="evenodd" d="M597.577 848.596C597.577 755.981 524.284 686.676 424.43 686.676H329.291L329.291 1010.26H373.588L424.43 1010.54C524.284 1010.54 597.577 941.21 597.577 848.596ZM373.588 726.364L424.43 726.364C502.765 726.364 554.508 778.365 554.508 848.596C554.508 918.826 502.765 970.857 424.43 970.857H373.588V726.364Z" fill="white"/> </g> <path d="M341.862 1217.87H322.699V1163.81H342.021C347.458 1163.81 352.139 1164.89 356.063 1167.06C359.988 1169.2 363.006 1172.29 365.117 1176.32C367.247 1180.35 368.311 1185.17 368.311 1190.79C368.311 1196.42 367.247 1201.26 365.117 1205.3C363.006 1209.35 359.97 1212.46 356.011 1214.62C352.069 1216.79 347.353 1217.87 341.862 1217.87ZM334.128 1208.08H341.387C344.766 1208.08 347.608 1207.48 349.913 1206.28C352.236 1205.07 353.978 1203.19 355.14 1200.66C356.319 1198.11 356.908 1194.82 356.908 1190.79C356.908 1186.79 356.319 1183.53 355.14 1180.99C353.978 1178.46 352.245 1176.59 349.939 1175.4C347.634 1174.2 344.792 1173.6 341.413 1173.6H334.128V1208.08ZM407.254 1217.87V1163.81H443.681V1173.23H418.684V1186.11H441.807V1195.54H418.684V1208.44H443.786V1217.87H407.254ZM493.01 1163.81L506.077 1204.88H506.578L519.671 1163.81H532.341L513.705 1217.87H498.976L480.314 1163.81H493.01ZM569.324 1217.87V1163.81H605.751V1173.23H580.753V1186.11H603.876V1195.54H580.753V1208.44H605.856V1217.87H569.324ZM645.313 1217.87V1163.81H656.743V1208.44H679.919V1217.87H645.313ZM765.537 1190.84C765.537 1196.73 764.419 1201.75 762.185 1205.88C759.967 1210.02 756.941 1213.18 753.104 1215.36C749.286 1217.53 744.992 1218.61 740.223 1218.61C735.419 1218.61 731.107 1217.52 727.289 1215.33C723.47 1213.15 720.452 1209.99 718.235 1205.86C716.017 1201.72 714.909 1196.72 714.909 1190.84C714.909 1184.94 716.017 1179.93 718.235 1175.79C720.452 1171.66 723.47 1168.51 727.289 1166.34C731.107 1164.16 735.419 1163.07 740.223 1163.07C744.992 1163.07 749.286 1164.16 753.104 1166.34C756.941 1168.51 759.967 1171.66 762.185 1175.79C764.419 1179.93 765.537 1184.94 765.537 1190.84ZM753.949 1190.84C753.949 1187.02 753.377 1183.8 752.233 1181.18C751.107 1178.56 749.514 1176.57 747.455 1175.21C745.397 1173.86 742.986 1173.18 740.223 1173.18C737.46 1173.18 735.049 1173.86 732.99 1175.21C730.931 1176.57 729.33 1178.56 728.186 1181.18C727.06 1183.8 726.497 1187.02 726.497 1190.84C726.497 1194.66 727.06 1197.88 728.186 1200.5C729.33 1203.12 730.931 1205.11 732.99 1206.46C735.049 1207.82 737.46 1208.5 740.223 1208.5C742.986 1208.5 745.397 1207.82 747.455 1206.46C749.514 1205.11 751.107 1203.12 752.233 1200.5C753.377 1197.88 753.949 1194.66 753.949 1190.84ZM804.48 1217.87V1163.81H825.808C829.908 1163.81 833.401 1164.59 836.287 1166.16C839.173 1167.71 841.373 1169.86 842.886 1172.62C844.417 1175.37 845.183 1178.54 845.183 1182.13C845.183 1185.72 844.408 1188.89 842.86 1191.63C841.311 1194.38 839.068 1196.51 836.129 1198.04C833.208 1199.58 829.67 1200.34 825.517 1200.34H811.923V1191.18H823.67C825.869 1191.18 827.682 1190.8 829.107 1190.05C830.55 1189.27 831.624 1188.21 832.328 1186.85C833.049 1185.48 833.41 1183.9 833.41 1182.13C833.41 1180.33 833.049 1178.77 832.328 1177.43C831.624 1176.07 830.55 1175.03 829.107 1174.29C827.664 1173.53 825.834 1173.15 823.617 1173.15H815.909V1217.87H804.48ZM883.083 1217.87V1163.81H919.51V1173.23H894.512V1186.11H917.635V1195.54H894.512V1208.44H919.615V1217.87H883.083ZM959.073 1217.87V1163.81H980.401C984.483 1163.81 987.968 1164.54 990.854 1166C993.757 1167.44 995.966 1169.49 997.479 1172.15C999.01 1174.79 999.776 1177.9 999.776 1181.47C999.776 1185.06 999.001 1188.15 997.453 1190.73C995.904 1193.3 993.66 1195.27 990.722 1196.65C987.801 1198.02 984.263 1198.7 980.11 1198.7H965.83V1189.52H978.263C980.445 1189.52 982.257 1189.22 983.7 1188.62C985.143 1188.02 986.217 1187.13 986.921 1185.93C987.642 1184.73 988.003 1183.25 988.003 1181.47C988.003 1179.67 987.642 1178.16 986.921 1176.93C986.217 1175.7 985.134 1174.76 983.674 1174.13C982.231 1173.48 980.41 1173.15 978.21 1173.15H970.502V1217.87H959.073ZM988.267 1193.27L1001.7 1217.87H989.085L975.94 1193.27H988.267ZM1086.01 1217.87V1163.81H1097.44V1208.44H1120.61V1217.87H1086.01ZM1170.09 1163.81V1217.87H1158.66V1163.81H1170.09ZM1257.67 1182.73H1246.11C1245.89 1181.24 1245.46 1179.91 1244.81 1178.75C1244.16 1177.57 1243.32 1176.57 1242.3 1175.74C1241.28 1174.91 1240.1 1174.28 1238.77 1173.84C1237.45 1173.4 1236.01 1173.18 1234.46 1173.18C1231.67 1173.18 1229.23 1173.87 1227.15 1175.26C1225.08 1176.64 1223.47 1178.64 1222.32 1181.28C1221.18 1183.9 1220.61 1187.09 1220.61 1190.84C1220.61 1194.69 1221.18 1197.93 1222.32 1200.55C1223.48 1203.17 1225.1 1205.15 1227.18 1206.49C1229.26 1207.83 1231.66 1208.5 1234.39 1208.5C1235.92 1208.5 1237.33 1208.3 1238.64 1207.89C1239.96 1207.49 1241.13 1206.9 1242.15 1206.12C1243.17 1205.33 1244.01 1204.37 1244.68 1203.24C1245.37 1202.12 1245.84 1200.83 1246.11 1199.39L1257.67 1199.44C1257.37 1201.92 1256.62 1204.32 1255.42 1206.62C1254.24 1208.91 1252.65 1210.96 1250.65 1212.77C1248.66 1214.57 1246.28 1215.99 1243.52 1217.05C1240.77 1218.09 1237.67 1218.61 1234.2 1218.61C1229.38 1218.61 1225.07 1217.52 1221.27 1215.33C1217.48 1213.15 1214.49 1209.99 1212.29 1205.86C1210.11 1201.72 1209.02 1196.72 1209.02 1190.84C1209.02 1184.94 1210.13 1179.93 1212.34 1175.79C1214.56 1171.66 1217.57 1168.51 1221.37 1166.34C1225.17 1164.16 1229.45 1163.07 1234.2 1163.07C1237.33 1163.07 1240.24 1163.51 1242.91 1164.39C1245.6 1165.27 1247.99 1166.55 1250.06 1168.24C1252.14 1169.91 1253.83 1171.97 1255.13 1174.39C1256.45 1176.82 1257.3 1179.6 1257.67 1182.73ZM1296.34 1217.87V1163.81H1332.77V1173.23H1307.77V1186.11H1330.89V1195.54H1307.77V1208.44H1332.87V1217.87H1296.34ZM1417.55 1163.81V1217.87H1407.67L1384.15 1183.84H1383.76V1217.87H1372.33V1163.81H1382.36L1405.69 1197.81H1406.17V1163.81H1417.55ZM1486.79 1179.36C1486.58 1177.23 1485.67 1175.57 1484.07 1174.39C1482.47 1173.21 1480.3 1172.62 1477.55 1172.62C1475.69 1172.62 1474.11 1172.89 1472.83 1173.42C1471.54 1173.93 1470.56 1174.64 1469.87 1175.55C1469.2 1176.47 1468.87 1177.51 1468.87 1178.67C1468.83 1179.64 1469.04 1180.48 1469.48 1181.2C1469.93 1181.93 1470.56 1182.55 1471.35 1183.08C1472.14 1183.59 1473.06 1184.04 1474.09 1184.42C1475.13 1184.79 1476.24 1185.11 1477.42 1185.37L1482.28 1186.54C1484.64 1187.06 1486.8 1187.77 1488.77 1188.65C1490.74 1189.53 1492.45 1190.61 1493.89 1191.89C1495.33 1193.18 1496.45 1194.69 1497.24 1196.43C1498.05 1198.18 1498.47 1200.17 1498.48 1202.43C1498.47 1205.73 1497.62 1208.6 1495.95 1211.03C1494.3 1213.44 1491.9 1215.32 1488.77 1216.65C1485.66 1217.97 1481.9 1218.63 1477.5 1218.63C1473.14 1218.63 1469.33 1217.96 1466.1 1216.63C1462.88 1215.29 1460.36 1213.31 1458.55 1210.69C1456.75 1208.05 1455.81 1204.78 1455.72 1200.9H1466.78C1466.91 1202.71 1467.43 1204.22 1468.34 1205.44C1469.27 1206.63 1470.51 1207.54 1472.06 1208.15C1473.63 1208.75 1475.4 1209.05 1477.37 1209.05C1479.3 1209.05 1480.98 1208.77 1482.41 1208.21C1483.85 1207.64 1484.97 1206.86 1485.76 1205.86C1486.55 1204.85 1486.95 1203.7 1486.95 1202.4C1486.95 1201.19 1486.59 1200.17 1485.87 1199.34C1485.16 1198.51 1484.13 1197.81 1482.75 1197.23C1481.4 1196.65 1479.73 1196.12 1477.76 1195.64L1471.88 1194.16C1467.32 1193.06 1463.72 1191.32 1461.08 1188.96C1458.44 1186.61 1457.13 1183.43 1457.15 1179.44C1457.13 1176.16 1458 1173.3 1459.76 1170.86C1461.54 1168.41 1463.98 1166.5 1467.07 1165.13C1470.17 1163.76 1473.69 1163.07 1477.63 1163.07C1481.64 1163.07 1485.15 1163.76 1488.14 1165.13C1491.15 1166.5 1493.49 1168.41 1495.16 1170.86C1496.83 1173.3 1497.69 1176.14 1497.75 1179.36H1486.79ZM1536.65 1217.87V1163.81H1573.08V1173.23H1548.08V1186.11H1571.2V1195.54H1548.08V1208.44H1573.18V1217.87H1536.65Z" fill="white"/> <defs> <clipPath id="clip0_736_195"> <rect width="1249.71" height="335.718" fill="white" transform="translate(329.291 682)"/> </clipPath> </defs> </svg>';
        _imageToken = Base64.encode(bytes(image));
        _imageContract = Base64.encode(bytes(image));

        string memory description = "This is an NFT collection minted for developers building on the DIMO Network.";
        _descriptionToken = description;
        _descriptionContract = description;
    }

    /*//////////////////////////////////////////////////////////////
                          Admin Functions
    //////////////////////////////////////////////////////////////*/

    function setImageToken(string calldata image_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _imageToken = Base64.encode(bytes(image_));
    }

    function setImageContract(string calldata image_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _imageContract = Base64.encode(bytes(image_));
    }

    function setDescriptionToken(string calldata description_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _descriptionToken = description_;
    }

    function setDescriptionContract(string calldata description_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _descriptionContract = description_;
    }

    /*//////////////////////////////////////////////////////////////
                            NFT Metadata
    //////////////////////////////////////////////////////////////*/

    function contractURI() external view returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"DIMO Developer License",'
                            '"description":', _descriptionContract, ','
                            '"image": "',
                            "data:image/svg+xml;base64,",
                            _imageContract,
                            '",' '"external_link": "https://dimo.zone/",'
                            '"collaborators": ["0x0000000000000000000000000000000000000000"]}'
                        )
                    )
                )
            )
        );
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            string(abi.encodePacked("DIMO Developer License #", Strings.toString(tokenId))),
                            '", "description":"',
                            _descriptionToken,
                            '", "image": "',
                            "data:image/svg+xml;base64,",
                            _imageToken,
                            '"}'
                        )
                    )
                )
            )
        );
    }

}