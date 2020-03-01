//
//  SPIPairingHelperTests.m
//  SPIClient-iOSTests
//
//  Created by Yoo-Jin Lee on 2017-11-26.
//  Copyright © 2017 mx51. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SPIPairing.h"
#import "SPIPairingHelper.h"
#import "SPISecrets.h"
#import "SPIMessage.h"

@interface SPIPairingHelperTests : XCTestCase
@end

@implementation SPIPairingHelperTests

- (void)testPairingKeyResponse {
    SPISecrets *secrets = nil;
    NSString *incomingMessageJsonStr = [self incomingKeyRequestJson];
    SPIMessage *incomingMessage = [SPIMessage fromJson:incomingMessageJsonStr secrets:nil];

    XCTAssertEqualObjects(@"key_request", incomingMessage.eventName);

    SPIKeyRequest *keyRequest = [[SPIKeyRequest alloc] initWithMessage:incomingMessage];
    SPISecretsAndKeyResponse *result = [SPIPairingHelper generateSecretsAndKeyResponseForKeyRequest:keyRequest];

    secrets = result.secrets;

    SPIKeyResponse *keyResponse = result.keyResponse;
    XCTAssertNotNil(keyResponse.benc);
    XCTAssertNotNil(keyResponse.bhmac);
    XCTAssertEqualObjects(@"62", keyResponse.requestId);

    SPIMessage *msgToSend = [keyResponse toMessage];
    NSString *enc  = [msgToSend getDataDictionaryValue:@"enc"][@"B"];
    NSString *hmac = [msgToSend getDataDictionaryValue:@"hmac"][@"B"];

    XCTAssertNotNil(enc);
    XCTAssertNotNil(hmac);
}

- (void)testCalculateMyPublicKeyAndSecret {
    NSString *theirPublicKey = @"E4B931D88827E1EB35BFF149A8B5CB8C77BF7C6DC42C96B573588710BF476EF0091A1B0604815D0BD884386CC6BA768DCB858D308391FDF112B0A92414E2E62B96F3C922CD215374F59FF202BE9B555EFF6DFA932F47E6319455AE20432144C57C8BC969D36EAA1D983DEEB48B2A274A2B9E1AE00F4CC0BCC98E86B1649AD2AAA364BAC9C40F479CF474BACDDB6511619DF8161767B43385F806C67749E0DF94DD6746CDB338E581CFE087D126425E93414C72BAC373345C46A82A2DDB1B6CDC3F43E736384E4A6C800CEA2A2F9D2819B60CEADE8A9A6F7AA59478EB4C242E76D22F3DDAC5DAA00CE4DF3E65AD140E50FD672E524ABB179E464BF6CF99D25AC3";

    SPIPublicKeyAndSecret *encPubAndSec = [SPIPairingHelper calculateMyPublicKeyAndSecret:theirPublicKey];
    XCTAssertTrue(![@"0" isEqualToString:encPubAndSec.myPublicKey]);
    XCTAssertTrue(![@"0" isEqualToString:encPubAndSec.sharedSecretKey]);
}

- (void)testSpiAHexStringToBigInteger {
    NSString *incoming = @"DE42490C8F4F6D4D94C6EF91FE14C88CC81EAF1E67B8F1F40AF0E7F820E9DA3C0A94B9ACC6A624BD119C3270910D925D351F097C859356A048E0FE9154C1AAB7CC69C125B55455C1E5B0A3790D2AA65A5AA3E2BB60CCF0F140E32ADEB5931245BECD361DE6070436EB54329972C86C01141EBCDB190B24789F05372D95219693DFC484F4FA04BDA808911835344145B5EC1AC277103FCC042DFFA19B081745C2A286ED378068165C289BCE4E66C25D959416F5CD493B37CD051D09505FC4166DB1B77253693F7671B5019945DF1DA561AB3514AAA2F665A6F80610ADC6B7E8B149FDC62E6A289A2E91708ECD68C98AC34A5138869CE387C0813B72DFC4013DCC";

    NSString *expected = @"28057590225756641307990478575115942434087786432814243319932776727076438406521076596140114483936714752816261267076418421365582967840892369393410969737840494345407097935234656169358022904124610557991122629465181790672063793938502648166037000156854900527078271865860807536279471604640419277958287835405482406786942622132480633555138157731306330505014921731704281742225329497728638630895408406470042417047793985972099848310146938210045502000965935203871114530585068895834412190170964682990662520608415632041868324548288922663465883289142775376591626822575267795629370129550324552253761158326240672561176761746423986339276";

    JKBigInteger *result = [SPIPairingHelper spiAHexStringToBigIntegerForHexStringA:incoming];

    XCTAssertEqualObjects(result.stringValue, expected);
}

- (void)testSpiAHexStringToBigInteger_2 {
    NSString *incoming = @"CA8A33B81963BAC7068FF4FA21193FD54445C47EE5D6EAC14B97C1DBD0AE21D683CB5BC355B16BE969B567536985177FCF446DD95B4A0B45A4D3FD497C6FEADB0126CD2383C0DA475B482007D4B941641EC82E177321292103B842660B1A9690E892A4E8D0664A4A50102B01F6562EBD480DC3B16D8BE5EE5ED076099CABB44330BA8124582669BEA1A3990754B9D9FB41F470539558B54C398628553B366ADDD5055C7EE784F916E44FFA8188E96C635F2314181BE662EE3125F0D119490132DD3F6C778199A11D80E182565C1CA05582988824ACF4E1CE84ECCE1F17FBE8BF9BB86D8C059A1E2114F96F163E0C45E6DEDA41DD27187A7CB696BD7F7032E";

    NSString *expected = @"6242257705828984036656266600403397573397224990025429675853955473612201444359563013179842155682812885831396293418099698228546742104443715887407249098046261687995142454490054830537910056555738078918996622954400366037842515342200987294449506875517728947106125309850920720564574130849595667906600652966151947593406017393637289292641140821958942411236880001806160003295142004163227450419959475352141829824638220928883338755038418821169677357987142679463603775052047306995489677114235996408400789487599802214581742956123668820445766837730477438131320464040402782216170369457291283600982299724185897733491544121861931822";

    JKBigInteger *result = [SPIPairingHelper spiAHexStringToBigIntegerForHexStringA:incoming];

    XCTAssertEqualObjects(result.stringValue, expected);
}

- (void)testSecretConversion {
    JKBigInteger *dhSecretBI = [[JKBigInteger alloc] initWithString:@"17574532284595554228770542578145458081719781058045063175688772743423924399411406200223997425795977226735712284391179978852253613346926080761628802664085045531796220784085311215093471160914442692274980632286568900367895454304533334450617380428362254473222831478193415222881689923861172428575632214297967550826460508634891791127942687630353829719246724903147169063379750256523005309264102997944008112551383251560153285483075803832550164760264165682355751637761390244202226339540318827287797180863284173748514677579269180126947721499144727772986832223499738071139796968492815538042908414723947769999062186130240163854083"];
    NSString *expectedSecret = @"7D3895D92143692B46AEB66C66D7023C008093F2D8E272954898918DF12AAAD7";
    NSString *calculatedSecret = [SPIPairingHelper dhSecretToSPISecret:dhSecretBI];

    XCTAssertEqualObjects(calculatedSecret, expectedSecret);
}

- (void)testSecretConversion2 {
    JKBigInteger *dhSecretBI = [[JKBigInteger alloc] initWithString:@"17574532284595554228770542578145458081719781058045063175688772743423924399411406200223997425795977226735712284391179978852253613"];
    NSString *expectedSecret   = @"238A19795053605B1995E678C7785FB1E2137E6F49F13CCAFFAC0CB9773AF3B1";
    NSString *calculatedSecret = [SPIPairingHelper dhSecretToSPISecret:dhSecretBI];

    XCTAssertEqualObjects(calculatedSecret, expectedSecret);

    NSLog(@"%@", [self incomingKeyRequestJson]);
}

- (NSString *)incomingKeyRequestJson {
    return @"{\"message\": {\n"
           "      \"event\": \"key_request\",\n"
           "         \"id\": \"62\",\n"
           "       \"data\": {\n"
           "          \"enc\": {\n"
           "             \"A\": \"17E7BE43D53102647040FC090000C215810E28E5E0CBD4F47923E194AE72AB0CDADF922642B73C568AA94A84B61874A475549E1F95847BE2725462E3D635F019BE39B2064F1EFFBE6B80CE97FBB7C0913ADC06A2445980B57647778B127FFCCE8B28A44BADEDE0110A5AFB05FEF7AA3F54988AFB04310A113F713601683D8E30CA2BAFC2EC34879127019E3352D8CAB9603184283AE3C9359D40C12474500018B8640AF371DC8712A06A3A443DF41DA9C1C60FAD2ACB02564A6694382B18811AA30CE38A1FC251DE0669504CAB620C2BA4A84CCC8FBDCBB30BBB3EACA76008599F74C2FDF6231773DC0439969CB5F2904A71DDF57F7DF9394AA29CBE4856FC82\"\n"
           "         },\n"
           "      \"hmac\": {\n"
           "         \"A\": \"89708531EADF129B4F67F00ECBF883C825A0EF3D766E32BC2BA13508B53FC3F5928316DE05CBE82FA1BBF4116E58A68C6F9C3C8FEF492051498188F4E80F82D5764FF50331B34E418E41480FAE0C794F20D9F7AE9819CB317AD2351B165783D57D12C39F95D9A5A292B89D3A26F9BBDE5C218EEC3FE63D910DCB0E1A0E6B570AF94BBD3025EB5E23FFBD9E8D58FE68403B3E50566DA8E2E54EED1A4D754689ECB7266B3D4804E39FB868F1741896757E7844C3389DA49F87D23FB2E9F6ADDBE9C14CC92F322CF3B471CE217E48D0762D5C963827AA6F4316B905F19E0262A35DC4B62E2FB95B7AAD5616C61F31C9A74008EE51BAB2CD6F646320FA30A6DDC4D7\"\n"
           "       }\n"
           "      }\n"
           "   }\n"
           "}";
}

@end
