import * as functions from 'firebase-functions';
import { Either, Right, Left } from 'purify-ts/Either';
import fetch from 'cross-fetch';

export default async function buildNetlify(): Promise<Either<string, globalThis.Response>> {
	try {
		const request = await fetch(functions.config().netlify.buidhook, { method: 'POST' });
		return Right(request);
	} catch (e) {
		return Left(`Netlify Build Hook failed ${e}`);
	}
}
