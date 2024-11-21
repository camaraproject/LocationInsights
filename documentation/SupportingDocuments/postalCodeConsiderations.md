# Most Frequent Location API

## Considerations about 'postalCode' and Country Name

This document consolidates the discussion of the issue https://github.com/camaraproject/LocationInsights/issues/7 

### Problem description
Postal code is not globally unique. For example, 31000 is Pamplona in Spain and Toulouse in France. In most cases the country can be derived from the phone number, but there can be other more sophisticated cases.
Making postal code unique should help to detect error API calls.

### Assumptions to solve and simplify the problem

**Actors**: Application service provider (ASP), ASP:User, End-User, Communication Service Provider (CSP).

**Assumptions**:
1. The End-User has a valid contract with a CSP in a specific country.
2. The CSP calculates the most frequent location insight of an End-User for that country where the CSP provides the service to the End-User.
3. The CSP can't provide the most frequent location insight for a country different from that of the contract.
4. The Application Service Provider User (ASP:User) wants to verify the most frequent location of the End-User using the 'phoneNumber' parameter of the API, which includes the country prefix.
6. The ASP:User assumes that the most frequent location insight is calculated for the country referred by the country prefix of the MSISDN.

**Under these assumptions, the MFL API will return the insight expected by the ASP:User, and no additional parameter, such as 'countryName' is needed.**

Any usage of the API out of these assumptions could provide misleading responses. For example, corner cases related with roaming, federation, or even coincident postal codes.

## Other considerations

If a common definition related to 'postalCode' is eventually specified at https://github.com/camaraproject/Commonalities, it will be reviewed for the evolution of this API.

The only related issue so far does not consider 'postalCode': https://github.com/camaraproject/Commonalities/pull/315